import 'dart:core';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../widgets/GradBtn.dart';
import '../widgets/Seeker_BottomNavi.dart';
import '../widgets/StatCard.dart';
import '../provider/app_provider.dart';
import 'package:ajeer/models/SeekerProfile.dart';
import 'package:ajeer/models/jobapplication.dart';
import 'package:ajeer/models/Job.dart';
import 'package:ajeer/Theme/app_theme.dart';
import '../Translations/translations.dart';
import 'package:ajeer/widgets/EmptyState.dart';

class MatcherScreen extends StatefulWidget {
  const MatcherScreen({super.key});
  @override
  State<MatcherScreen> createState() => _MatcherScreenState();
}

class _MatcherScreenState extends State<MatcherScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  List<Map<String, dynamic>> _results = [];
  bool _ran = false, _loading = false;

  @override
  void initState() {
    super.initState();
    _pulse =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    final prov = context.read<AppProvider>();
    if (prov.seeker.skills.isEmpty) {
      context.go('/profile');
      return;
    }
    setState(() {
      _loading = true;
      _ran = false;
    });

    // Call real backend MatchingService — GET /jobs/match
    // scores by skills + city + availability and returns ranked list
    final results = await prov.fetchTopMatches();

    if (!mounted) return;
    setState(() {
      _results = results.map((r) {
        final raw = r['score'];
        return {
          ...r,
          'score': raw is int ? raw : (raw as num).round(),
        };
      }).toList();
      _ran = true;
      _loading = false;
    });
  }

  Color _color(int s) {
    // Thresholds mirror MatchingService::label()
    if (s >= 90) return AppTheme.accent; // Excellent Match
    if (s >= 70) return AppTheme.success; // Strong Match
    if (s >= 50) return AppTheme.primary; // Good Match
    if (s >= 30) return AppTheme.warning; // Partial Match
    return AppTheme.textMuted; // Low Match
  }

  String _label(int s, String Function(String) t) {
    // Mirror MatchingService::label() — use backend label if available
    if (s >= 90) return 'Excellent Match';
    if (s >= 70) return 'Strong Match';
    if (s >= 50) return 'Good Match';
    if (s >= 30) return 'Partial Match';
    return 'Low Match';
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final lang = prov.lang;
    final t = (String k) => Tr.get(k, lang);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(t('smart Matcher')),
        actions: [
          IconButton(
              icon: const Icon(Icons.translate_rounded),
              onPressed: prov.toggleLang),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          // ── AI header ────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
            decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(24)),
            child: Column(children: [
              AnimatedBuilder(
                animation: _pulse,
                builder: (_, child) => Transform.scale(
                    scale: 1.0 + _pulse.value * 0.07, child: child),
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.white.withOpacity(0.1), blurRadius: 30)
                    ],
                  ),
                  child: const Icon(Icons.auto_awesome_rounded,
                      color: Colors.white, size: 46),
                ),
              ),
              const SizedBox(height: 16),
              Text(t('aiTitle'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(t('aiSub'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.8), fontSize: 13)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _loading ? null : _run,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.accent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 13)),
                icon: _loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.auto_awesome_rounded),
                label: Text(_loading ? t('analyzing') : t('runAI'),
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ]),
          ),
          const SizedBox(height: 20),

          // ── Skills preview (before run) ───────────────────────
          if (!_ran)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.card,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.person_rounded, color: AppTheme.primary),
                      const SizedBox(width: 8),
                      Text(t('myProfile'),
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                    ]),
                    const Divider(height: 20),
                    if (prov.seeker.skills.isEmpty)
                      Column(children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.warning.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppTheme.warning.withOpacity(0.3)),
                          ),
                          child: Row(children: [
                            const Icon(Icons.warning_amber_rounded,
                                color: AppTheme.warning),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(t('needsProfile'),
                                  style: const TextStyle(
                                      color: AppTheme.warning, fontSize: 13)),
                            ),
                          ]),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => context.go('/profile'),
                            icon: const Icon(Icons.edit_rounded),
                            label: Text(t('goToProfile')),
                          ),
                        ),
                      ])
                    else ...[
                      Text(t('mySkills'),
                          style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: prov.seeker.skills
                            .map((s) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 5),
                                  decoration: BoxDecoration(
                                      gradient: AppTheme.primaryGradient,
                                      borderRadius: BorderRadius.circular(50)),
                                  child: Text(s.name, // was hardcoded "Skills"
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600)),
                                ))
                            .toList(),
                      ),
                    ],
                  ]),
            ),

          // ── Results ──────────────────────────────────────────
          if (_ran) ...[
            if (_results.isEmpty)
              EmptyState(
                  icon: Icons.search_off_rounded,
                  title: t('noJobs'),
                  subtitle: t('searchHint'))
            else ...[
              // Summary
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.success.withOpacity(0.2)),
                ),
                child: Row(children: [
                  const Icon(Icons.check_circle_rounded,
                      color: AppTheme.success),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Found ${_results.length} matched jobs · Avg score: ${_avgScore()}%',
                      style: const TextStyle(
                          color: AppTheme.success,
                          fontWeight: FontWeight.w600,
                          fontSize: 13),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 16),
              SectionHeader(title: t('topMatches')),
              const SizedBox(height: 12),

              ..._results.asMap().entries.map((e) {
                final i = e.key;
                final resultMap = e.value;

                // Backend returns 'job' as a Map<String,dynamic> from formatJob().
                // Extract fields safely instead of casting to Job model.
                final jobMap = resultMap['job'] as Map<String, dynamic>? ?? {};
                final jobTitle = jobMap['title']?.toString() ?? '';
                final jobLocation = jobMap['location']?.toString() ?? '';
                final jobSalary = jobMap['salary']?.toString();
                final jobId = (jobMap['job_id'] as num?)?.toInt() ?? 0;
                final jobSkills = (jobMap['skills'] as List<dynamic>? ?? [])
                    .map((s) => s['skill_name']?.toString() ?? '')
                    .where((n) => n.isNotEmpty)
                    .toList();
                final isApplied = resultMap['applied'] == true;
                final breakdown =
                    resultMap['breakdown'] as Map<String, dynamic>?;

                final score = resultMap['score'] as int;
                final col = _color(score);

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: AppTheme.card,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                  gradient: AppTheme.primaryGradient,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Center(
                                child: Text('${i + 1}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 14)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(jobTitle,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15)),
                                    Text(jobLocation,
                                        style: const TextStyle(
                                            color: AppTheme.textMuted,
                                            fontSize: 12)),
                                  ]),
                            ),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('$score%',
                                      style: TextStyle(
                                          color: col,
                                          fontSize: 26,
                                          fontWeight: FontWeight.w900)),
                                  Text(t('matchRate'),
                                      style: const TextStyle(
                                          color: AppTheme.textMuted,
                                          fontSize: 10)),
                                ]),
                          ]),
                          const SizedBox(height: 12),

                          // Progress bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: score / 100,
                              minHeight: 9,
                              backgroundColor: Colors.grey.shade100,
                              valueColor: AlwaysStoppedAnimation(col),
                            ),
                          ),
                          const SizedBox(height: 4),

                          Text(
                            '${_label(score, t)} · $jobLocation · '
                            '${jobSalary != null ? '${double.tryParse(jobSalary)?.toStringAsFixed(0) ?? jobSalary} JD/mo' : '—'}',
                            style: const TextStyle(
                                color: AppTheme.textMuted, fontSize: 11),
                          ),
                          const SizedBox(height: 12),

                          // Skills chips — highlight those the seeker has
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: jobSkills.take(5).map((skillName) {
                              final matched =
                                  prov.seeker.skillNames.contains(skillName);
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: matched
                                      ? AppTheme.success.withOpacity(0.1)
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(
                                      color: matched
                                          ? AppTheme.success.withOpacity(0.4)
                                          : Colors.transparent),
                                ),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (matched) ...[
                                        const Icon(Icons.check_rounded,
                                            size: 12, color: AppTheme.success),
                                        const SizedBox(width: 3),
                                      ],
                                      Text(skillName,
                                          style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: matched
                                                  ? AppTheme.success
                                                  : AppTheme.textMuted)),
                                    ]),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 12),

                          // Breakdown row (skills/city/availability scores)
                          if (breakdown != null) ...[
                            _BreakdownRow(breakdown: breakdown),
                            const SizedBox(height: 12),
                          ],
                          SizedBox(
                            width: double.infinity,
                            child: isApplied || prov.hasApplied(jobId)
                                ? Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    decoration: BoxDecoration(
                                      color: AppTheme.success.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: AppTheme.success
                                              .withOpacity(0.3)),
                                    ),
                                    child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.check_circle_rounded,
                                              color: AppTheme.success,
                                              size: 16),
                                          SizedBox(width: 6),
                                          Text('Applied ✓',
                                              style: TextStyle(
                                                  color: AppTheme.success,
                                                  fontWeight: FontWeight.w700)),
                                        ]),
                                  )
                                : ElevatedButton.icon(
                                    onPressed: () async {
                                      final ok = await prov.applyToJob(jobId);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text(ok
                                              ? '✅ Applied!'
                                              : '⚠️ Already applied'),
                                          backgroundColor: ok
                                              ? AppTheme.success
                                              : AppTheme.warning,
                                          behavior: SnackBarBehavior.floating,
                                        ));
                                      }
                                    },
                                    icon: const Icon(Icons.send_rounded,
                                        size: 16),
                                    label: Text(t('applyNow')),
                                  ),
                          ),
                        ]),
                  ),
                );
              }),
            ],
          ],
          const SizedBox(height: 80),
        ]),
      ),
      bottomNavigationBar: const SeekerBottomNav(index: 1),
    );
  }

  int _avgScore() {
    if (_results.isEmpty) return 0;
    return (_results.fold<int>(0, (s, m) {
              final raw = m['score'];
              return s + (raw is int ? raw : (raw as num).round());
            }) /
            _results.length)
        .round();
  }
}

// ── Breakdown widget — shows skills/city/availability scores from backend ──
class _BreakdownRow extends StatelessWidget {
  final Map<String, dynamic> breakdown;
  const _BreakdownRow({required this.breakdown});

  @override
  Widget build(BuildContext context) {
    final skills = breakdown['skills'] as Map<String, dynamic>? ?? {};
    final city = breakdown['city'] as Map<String, dynamic>? ?? {};
    final avail = breakdown['availability'] as Map<String, dynamic>? ?? {};

    return Row(children: [
      _BreakdownChip(
        icon: Icons.construction_rounded,
        label: 'Skills',
        value: (skills['matched'] != null && skills['total_required'] != null)
            ? '${skills['matched']}/${skills['total_required']}'
            : '—',
        hit: (skills['score'] as num? ?? 0) > 0,
      ),
      const SizedBox(width: 6),
      _BreakdownChip(
        icon: Icons.location_on_rounded,
        label: 'City',
        value: city['matched'] == true ? '✓' : '✗',
        hit: city['matched'] == true,
      ),
      const SizedBox(width: 6),
      _BreakdownChip(
        icon: Icons.schedule_rounded,
        label: 'Shifts',
        value:
            (avail['matched_shifts'] != null && avail['total_shifts'] != null)
                ? '${avail['matched_shifts']}/${avail['total_shifts']}'
                : '—',
        hit: (avail['score'] as num? ?? 0) > 0,
      ),
    ]);
  }
}

class _BreakdownChip extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final bool hit;
  const _BreakdownChip(
      {required this.icon,
      required this.label,
      required this.value,
      required this.hit});

  @override
  Widget build(BuildContext context) {
    final color = hit ? AppTheme.success : AppTheme.textMuted;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 7),
        decoration: BoxDecoration(
          color: hit ? AppTheme.success.withOpacity(0.07) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: hit
                  ? AppTheme.success.withOpacity(0.3)
                  : Colors.grey.shade200),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Expanded(
            child: Text('$label: $value',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 10, color: color, fontWeight: FontWeight.w600)),
          ),
        ]),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
      ),
    );
  }
}
