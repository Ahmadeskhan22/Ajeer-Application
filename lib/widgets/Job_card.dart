import 'package:ajeer/widgets/private_helpers/MetaChip.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../provider/app_provider.dart';
import 'package:ajeer/models/SeekerProfile.dart';
import '../models/Job.dart';
import '../Theme/app_theme.dart';
import '../Translations/translations.dart';
import '../widgets/PRIVATE_HELPERS/SkillChip.dart';
import '../widgets/StatCard.dart';

import 'PRIVATE_HELPERS/AppliedBadge.dart';
import 'PRIVATE_HELPERS/CompanyAvatar.dart';

//  4. JOB CARD  (Seeker perspective only)
//
//  Shows a single job the way a seeker sees it:
//    • Company avatar + title + salary pill
//    • Location · type · category
//    • Skill chips → GREEN if the seeker has it, GREY if not
//    • "Apply Now" button → becomes "Applied ✓" after applying
//
//  This card has NO manage-applicants button, NO edit/delete
//  controls. Those are employer actions. This app has no employer.
//
//  job      — Job object to display (required)
//  onApply  — called when seeker taps "Apply Now"
//  compact  — true = small preview, no apply button, 3 skill chips
//             false (default) = full card, apply button, 5 chips
/*

 */
class JobCard extends StatelessWidget {
  final Job job;
  final VoidCallback? onApply;
  final bool compact;

  const JobCard({
    super.key,
    required this.job,
    this.onApply,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final lang = prov.lang;
    final t = (String k) => Tr.get(k, lang);

//We use the submission status coming directly from the server for each job
    final applied = job.applied;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.card,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header: Avatar + Title + Company Name
            Row(
              children: [
                // using name of Company for avatar
                CompanyAvatar(name: job.ownerName),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        job.ownerName, // Display company/employer name
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                if (applied)
                  const Icon(Icons.check_circle, color: Colors.green, size: 22),
              ],
            ),
            const SizedBox(height: 14),

            // 2. Meta Info: Location + Category
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                MetaChip(Icons.location_on_rounded, job.location),

                // As the category for the job (since the server sends the category with the skill) fetch the category of the first skill
                if (job.skills.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.category_rounded,
                            size: 14, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text(
                          job.skills.first.categoryName ?? "General",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),

            // 3. Skills: Database-driven Logic
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: job.skills.take(compact ? 3 : 5).map((skill) {
                // Logic: Does the user skill list contain the name of this skill?
                final matched = prov.seeker.skills.contains(skill.skillName);
                return SkillChip(skill: skill.skillName, matched: matched);
              }).toList(),
            ),

            const SizedBox(height: 16),

            // 4. Footer: Salary + Action Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t('salary') ?? "Salary",
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.textMuted),
                    ),
                    Text(
                      job.salary != null
                          ? "${job.salary} JOD"
                          : t('negotiable') ?? "Negotiable",
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                if (!compact)
                  applied
                      ? AppliedBadge(label: t('applied'))
                      : ElevatedButton.icon(
                          onPressed: onApply,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.send_rounded, size: 16),
                          label: Text(t('applyNow')),
                        ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
