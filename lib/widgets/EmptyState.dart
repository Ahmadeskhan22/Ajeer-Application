import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../provider/app_provider.dart';
import '../models/SeekerProfile.dart';
import '../models/Job.dart';
import '../Theme/app_theme.dart';
import '../Translations/translations.dart';

//  9. EMPTY STATE
//
//  Full-screen placeholder when a list is empty.
//  Examples:
//    • No applications yet  → "Browse jobs and start applying!"
//    • No jobs found        → nudge to clear filters
//
//  icon     — large icon at top
//  title    — bold heading
//  subtitle — muted helper text
//  btnLabel — optional action button label
//  onBtn    — optional action button callback
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? btnLabel;
  final VoidCallback? onBtn;
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.btnLabel,
    this.onBtn,
  });
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 72, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark),
            ),
            const SizedBox(height: 6),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 13,
                )),
            if (btnLabel != null) ...[
              const SizedBox(height: 20),
              OutlinedButton(onPressed: onBtn, child: Text(btnLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
