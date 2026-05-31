import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../provider/app_provider.dart';
import '../models/SeekerProfile.dart';
import '../models/Job.dart';
import '../Theme/app_theme.dart';
import '../Translations/translations.dart';

/*
  Orange banner shown when the seeker's profile is incomplete.
  Includes a thin progress bar and a "XX%" percentage.
 Tapping it routes the seeker directly to /profile.

 Why it matters:
    The AI Matcher scores jobs based on the seeker's skills.
   An empty profile = bad AI matches.
   This banner motivates the seeker to add skills and info.

  Auto-hides when profile completeness reaches 100%.

 Usage:
    Column(children: [
    const ProfileCompletionBanner(),
     ...other content


 */

class ProfileCompletionBanner extends StatelessWidget {
  const ProfileCompletionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final lang = prov.lang;
    final t = (String k) => Tr.get(k, lang);
    final pct = (prov.seeker.completeness * 100).round();

    // Fully complete → render nothing
    if (pct >= 100) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => context.go('/profile'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.warning.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.warning.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.person_outline_rounded,
                color: AppTheme.warning, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t('completeProfile'),
                    style: const TextStyle(
                      color: AppTheme.warning,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: prov.seeker.completeness,
                      minHeight: 5,
                      backgroundColor: AppTheme.warning.withOpacity(0.2),
                      valueColor:
                          const AlwaysStoppedAnimation(AppTheme.warning),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '$pct%',
              style: const TextStyle(
                color: AppTheme.warning,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppTheme.warning),
          ],
        ),
      ),
    );
  }
}
