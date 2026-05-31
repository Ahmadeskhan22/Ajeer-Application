import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '/provider/app_provider.dart';
import '/models/SeekerProfile.dart';
import '/models/Job.dart';
import '/Theme/app_theme.dart';
import '/Translations/translations.dart';

/// Gradient square with company initial — JobCard header
class CompanyAvatar extends StatelessWidget {
  final String name;
  const CompanyAvatar({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'J',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
