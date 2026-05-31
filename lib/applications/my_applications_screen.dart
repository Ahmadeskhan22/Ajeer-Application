import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Theme/app_theme.dart';
import '../Translations/translations.dart';
import '../models/jobapplication.dart';
import '../provider/app_provider.dart';
import '../widgets/Seeker_BottomNavi.dart';
import '../Ai_matching/MatcherScreen.dart';

// ── Status config ──────────────────────────────────────────────────────────
class _StatusStyle {
  final String label;
  final Color color;
  final Color bg;
  final IconData icon;
  const _StatusStyle(
      {required this.label,
      required this.color,
      required this.bg,
      required this.icon});
}

// Maps every API status → display style
// FIX: "Pending" is shown correctly; UI no longer shows raw "Pending" text where
// "Rejected" was expected — each status gets its own colour + icon.
_StatusStyle _styleFor(String status) {
  switch (status) {
    case 'Accepted':
      return const _StatusStyle(
        label: 'Accepted',
        color: Color(0xFF1B8A4B),
        bg: Color(0xFFE6F7EE),
        icon: Icons.check_circle_rounded,
      );
    case 'Rejected':
      return const _StatusStyle(
        label: 'Rejected',
        color: Color(0xFFB91C1C),
        bg: Color(0xFFFFEDED),
        icon: Icons.cancel_rounded,
      );
    case 'Canceled':
      return const _StatusStyle(
        label: 'Canceled',
        color: Color(0xFF6B7280),
        bg: Color(0xFFF3F4F6),
        icon: Icons.remove_circle_outline_rounded,
      );
    case 'Pending':
    default:
      return const _StatusStyle(
        label: 'Pending',
        color: Color(0xFFB45309),
        bg: Color(0xFFFFF7ED),
        icon: Icons.hourglass_top_rounded,
      );
  }
}

// ── Score chip colours ─────────────────────────────────────────────────────
Color _scoreColor(int score) {
  if (score >= 80) return const Color(0xFF1B8A4B);
  if (score >= 50) return const Color(0xFFB45309);
  return const Color(0xFFB91C1C);
}

// ═══════════════════════════════════════════════════════════════════════════
class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  // Filter: null = all
  String? _filterStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Refresh on open so status changes made by the employer are visible
      context.read<AppProvider>().fetchMyApplications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final t = (String k) => Tr.get(k, prov.lang);

    // Build match-score lookup from the backend /jobs/match data.
    // matchedJobs is List<Map> cached by fetchTopMatches(); key = job_id → score.
    final Map<int, int> matchScores = {};
    for (final m in prov.matchedJobs) {
      final job = m['job'];
      if (job != null) {
        final jobId = job['job_id'] as int?;
        final score = (m['score'] as num?)?.toInt();
        if (jobId != null && score != null) matchScores[jobId] = score;
      }
    }

    // ── Filter ──────────────────────────────────────────────────
    final filtered = _filterStatus == null
        ? prov.myApps
        : prov.myApps.where((a) => a.status == _filterStatus).toList();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(t('myApplications')),
        actions: [
          IconButton(
            icon: const Icon(Icons.translate_rounded),
            onPressed: prov.toggleLang,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _FilterBar(
            current: _filterStatus,
            onSelected: (v) => setState(() => _filterStatus = v),
          ),
        ),
      ),
      body: prov.isLoading
          ? const Center(child: CircularProgressIndicator())
          : filtered.isEmpty
              ? _EmptyApps(t: t)
              : RefreshIndicator(
                  onRefresh: prov.fetchMyApplications,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) => _AppCard(
                      app: filtered[i],
                      matchScore: matchScores[filtered[i].jobId],
                      onCancel: filtered[i].status == 'Pending'
                          ? () => _confirmCancel(
                              ctx, prov, filtered[i].applicationId)
                          : null,
                      t: t,
                    ),
                  ),
                ),
      bottomNavigationBar: const SeekerBottomNav(index: 3),
    );
  }

  Future<void> _confirmCancel(
      BuildContext ctx, AppProvider prov, int appId) async {
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Cancel Application'),
        content: const Text(
            'Are you sure you want to cancel this application? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(_, false),
              child: const Text('Keep')),
          TextButton(
            onPressed: () => Navigator.pop(_, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.danger),
            child: const Text('Cancel Application'),
          ),
        ],
      ),
    );
    if (confirmed == true && ctx.mounted) {
      final ok = await prov.cancelApplication(appId);
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
          content: Text(ok ? 'Application canceled.' : 'Could not cancel.'),
          backgroundColor: ok ? AppTheme.success : AppTheme.danger,
        ));
      }
    }
  }
}

// ── Filter tab bar ─────────────────────────────────────────────────────────
class _FilterBar extends StatelessWidget {
  final String? current;
  final ValueChanged<String?> onSelected;
  const _FilterBar({required this.current, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    const tabs = <String?>[
      'All',
      'Pending',
      'Accepted',
      'Rejected',
      'Canceled'
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: tabs.map((s) {
          final isAll = s == 'All';
          final selected = isAll ? current == null : current == s;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(s ?? 'All'),
              selected: selected,
              onSelected: (_) => onSelected(isAll ? null : s),
              selectedColor: AppTheme.primary,
              labelStyle: TextStyle(
                color: selected ? Colors.white : AppTheme.textMuted,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 12,
              ),
              backgroundColor: Colors.grey.shade100,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Application card ───────────────────────────────────────────────────────
class _AppCard extends StatelessWidget {
  final JobApplication app;
  final int? matchScore;
  final VoidCallback? onCancel;
  final String Function(String) t;

  const _AppCard({
    required this.app,
    required this.matchScore,
    required this.onCancel,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(app.status);
    final score = matchScore;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
        border: Border.all(
          color: style.color.withOpacity(0.25),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: title + status badge ──────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Job title & employer
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.jobTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      if (app.ownerName != null && app.ownerName!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Row(children: [
                            const Icon(Icons.business_rounded,
                                size: 13, color: AppTheme.textMuted),
                            const SizedBox(width: 4),
                            Text(app.ownerName!,
                                style: const TextStyle(
                                    fontSize: 12, color: AppTheme.textMuted)),
                          ]),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Status badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: style.bg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(style.icon, size: 14, color: style.color),
                    const SizedBox(width: 4),
                    Text(style.label,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: style.color)),
                  ]),
                ),
              ],
            ),
          ),

          // ── Meta row: location + salary + match score ──────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                if (app.location != null && app.location!.isNotEmpty)
                  _MetaChip(
                      icon: Icons.location_on_outlined, label: app.location!),
                if (app.salary != null && app.salary!.isNotEmpty)
                  _MetaChip(icon: Icons.payments_outlined, label: app.salary!),
                if (score != null)
                  _MetaChip(
                    icon: Icons.auto_awesome_rounded,
                    label: 'Match $score%',
                    color: _scoreColor(score),
                  ),
              ],
            ),
          ),

          // ── Skills chips ───────────────────────────────────────
          if (app.skills.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: app.skills.take(4).map((s) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(s,
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600)),
                  );
                }).toList(),
              ),
            ),

          // ── Shifts ─────────────────────────────────────────────
          if (app.shifts.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(children: [
                const Icon(Icons.schedule_rounded,
                    size: 14, color: AppTheme.textMuted),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    app.shifts
                        .take(2)
                        .map((sh) =>
                            '${sh['shift_date']} ${sh['shift_start']}–${sh['shift_end']}')
                        .join('  •  '),
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textMuted),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ]),
            ),

          // ── Applied date + optional cancel button ─────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 13, color: AppTheme.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(app.appliedAt),
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textMuted),
                  ),
                ]),
                if (onCancel != null)
                  GestureDetector(
                    onTap: onCancel,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.danger.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('Cancel',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.danger,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      final d = DateTime.parse(iso).toLocal();
      return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso.length > 10 ? iso.substring(0, 10) : iso;
    }
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _MetaChip(
      {required this.icon,
      required this.label,
      this.color = AppTheme.textMuted});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 3),
          Text(label,
              style: TextStyle(
                  fontSize: 12, color: color, fontWeight: FontWeight.w600)),
        ],
      );
}

class _EmptyApps extends StatelessWidget {
  final String Function(String) t;
  const _EmptyApps({required this.t});
  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.work_off_outlined, size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(t('noApplications'),
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textMuted)),
          const SizedBox(height: 8),
          Text(t('noApplicationsSub'),
              style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
              textAlign: TextAlign.center),
        ]),
      );
}
