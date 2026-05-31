import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Widgets/Job_card.dart';
import '../Widgets/Seeker_BottomNavi.dart';
import '../provider/app_provider.dart';
import '../Theme/app_theme.dart';
import '../Translations/translations.dart';
import '../Widgets/EmptyState.dart';
import '../models/Job.dart';
import '../widgets/CategoryFilterBar.dart'; // ✅ الـ Widget الديناميكي الخاص بك

class BrowseJobsScreen extends StatefulWidget {
  const BrowseJobsScreen({super.key});
  @override
  State<BrowseJobsScreen> createState() => _BrowseJobsScreenState();
}

class _BrowseJobsScreenState extends State<BrowseJobsScreen> {
  final _ctrl = TextEditingController();
  String _q = '';

  // ✅ التعديل هنا: تم استبدال النص بـ ID الفئة الرقمي القادم من الباك إند
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    // جلب الوظائف الحقيقية من السيرفر فور فتح الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().fetchJobs();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // دالة البحث التي تخاطب الباك إند مباشرة
  void _onSearch(String query, AppProvider prov) {
    setState(() => _q = query);
    prov.fetchJobs(search: query);
  }

  // دالة التقديم المحدثة لتتوافق مع السيرفر والـ ID الرقمي
  Future<void> _apply(BuildContext ctx, AppProvider prov, int jobId,
      String Function(String) t) async {
    final ok =
        await prov.applyToJob(jobId, message: "Interested in this position.");

    if (!ctx.mounted) return;

    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(ok ? Icons.check_circle_rounded : Icons.info_rounded,
            color: Colors.white),
        const SizedBox(width: 8),
        Text(ok ? '${t('applyNow')} ✓' : t('applied')),
      ]),
      backgroundColor: ok ? AppTheme.success : AppTheme.warning,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final lang = prov.lang;
    final t = (String k) => Tr.get(k, lang);

    // ── ✅ التعديل السحري: فلترة الوظائف ديناميكياً بناءً على فئة الباك إند ──
    String? targetCategoryName;
    if (_selectedCategoryId != null) {
      // البحث عن اسم الفئة داخل البيانات القادمة من السيرفر لربطها بالوظيفة
      final foundCat = prov.skillsCategories.firstWhere(
        (c) => (c['category_id'] as num?)?.toInt() == _selectedCategoryId,
        orElse: () => null,
      );
      targetCategoryName = foundCat?['category_name']?.toString();
    }

    // فلترة القائمة المحلية بناءً على اسم فئة المهارة المطلوبة للوظيفة
    // update list by the name of  list of skills required for Job
    final jobs = targetCategoryName == null
        ? prov.approvedJobs
        : prov.approvedJobs.where((job) {
            return job.skills.any((s) => s.categoryName == targetCategoryName);
          }).toList();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(t('browseJobs')),
        actions: [
          IconButton(
              icon: const Icon(Icons.translate_rounded),
              onPressed: prov.toggleLang),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _ctrl,
              onChanged: (v) => _onSearch(v, prov),
              decoration: InputDecoration(
                hintText: t('searchHint'),
                prefixIcon:
                    const Icon(Icons.search_rounded, color: AppTheme.primary),
                suffixIcon: _q.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _ctrl.clear();
                          _onSearch('', prov);
                        })
                    : null,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ),
      ),
      body: Column(children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
          child: CategoryFilterBar(
            selectedCategoryId: _selectedCategoryId,
            onSelected: (id) {
              setState(() {
                _selectedCategoryId = id; //Update ID
              });
            },
          ),
        ),
        const Divider(height: 1),

        // ── Count line ──────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
          child: Row(children: [
            Text(
              '${jobs.length} ${t('jobs')} (${t('statusApproved')})',
              style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
            ),
          ]),
        ),

        // ── Job list ─────────────────────────
        Expanded(
          child: prov.isLoading
              ? const Center(child: CircularProgressIndicator())
              : jobs.isEmpty
                  ? EmptyState(
                      icon: Icons.work_off_rounded,
                      title: t('noJobs'),
                      subtitle: t('searchHint'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: jobs.length,
                      itemBuilder: (ctx, i) => JobCard(
                        job: jobs[i],
                        onApply: () => _apply(ctx, prov, jobs[i].jobId, t),
                      ),
                    ),
        ),
      ]),
      bottomNavigationBar: const SeekerBottomNav(index: 0),
    );
  }
}
