import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '/provider/app_provider.dart';
import '/models/SeekerProfile.dart';
import '/models/Job.dart';
import '/Theme/app_theme.dart';
import '/Translations/translations.dart';

/// Blue salary pill — JobCard header
class SalaryChip extends StatelessWidget {
  final int salary;
  final String unit;
  const SalaryChip({required this.salary, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        '$salary $unit',
        style: const TextStyle(
          color: AppTheme.primary,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

/// Icon + label — location / type / category inside JobCard
class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _MetaChip(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppTheme.textMuted),
        const SizedBox(width: 3),
        Text(text,
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
      ],
    );
  }
}
