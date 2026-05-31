import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../provider/app_provider.dart';
import '../models/SeekerProfile.dart';
import '../models/Job.dart';
import '../Theme/app_theme.dart';
import '../Translations/translations.dart';

//  5. SEEKER STAT CARD
//
//  Coloured metric tile used on the Profile screen (three in a Row):
//    Applied  (blue)  · Pending (orange) · Accepted (green)
//
//  These are seeker-side stats only — no employer metrics.
//
//  Must be placed inside a Row because it uses Expanded internally.

class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                  color: color, fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
