import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '/provider/app_provider.dart';
import 'package:ajeer/models/SeekerProfile.dart';
import 'package:ajeer/models/jobapplication.dart';
import 'package:ajeer/models/Job.dart';
import 'package:ajeer/Theme/app_theme.dart';

import '/Translations/translations.dart';

class AppliedBadge extends StatelessWidget {
  final String label;
  const AppliedBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.success.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.success.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_rounded,
              color: AppTheme.success, size: 18),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.success,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
