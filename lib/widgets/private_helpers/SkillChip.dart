import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '/provider/app_provider.dart';
import '/models/SeekerProfile.dart';
import '/models/Job.dart';
import '/Theme/app_theme.dart';
import '/Translations/translations.dart';

/// Skill tag inside JobCard
/// matched = true  → green, seeker has this skill
/// matched = false → grey, seeker doesn't have it
class SkillChip extends StatelessWidget {
  final String skill;
  final bool matched;
  const SkillChip({required this.skill, required this.matched});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color:
            matched ? AppTheme.success.withOpacity(0.1) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color:
              matched ? AppTheme.success.withOpacity(0.4) : Colors.transparent,
        ),
      ),
      child: Text(
        skill,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: matched ? AppTheme.success : AppTheme.textMuted,
        ),
      ),
    );
  }
}
