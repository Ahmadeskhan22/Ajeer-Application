import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../provider/app_provider.dart';
import '../models/SeekerProfile.dart';
import '../models/Job.dart';
import '../Theme/app_theme.dart';
import '../Translations/translations.dart';
//  6. APPLICATION STATUS BADGE
//
//  Pill-shaped badge showing what happened to one of the seeker's
//  applications after the employer reviewed it.
//
//  'new'      → "Under Review"  orange  ⏳
//  'accepted' → "Accepted"      green   ✅
//  'rejected' → "Rejected"      red     ✖
//
//  Usage:
//    ApplicationStatusBadge(status: app.status, t: t)

class ApplicationStatusBadge extends StatelessWidget {
  final String status; // 'new' | 'accepted' | 'rejected'
  final String Function(String) t;

  const ApplicationStatusBadge({
    super.key,
    required this.status,
    required this.t,
  });

  Color get _color => switch (status) {
        'accepted' => AppTheme.success,
        'rejected' => AppTheme.danger,
        _ => AppTheme.warning, //to switch between two state
      };
  IconData get _icon => switch (status) {
        'accepted' => Icons.check_circle_rounded,
        'rejected' => Icons.cancel_rounded,
        _ => Icons.hourglass_empty_rounded, //to switch between two state
      };
  String get _label => switch (status) {
        'accepted' => t('statusAccepted'),
        'rejected' => t('statusRejected'),
        _ => t('statusNew'),
      };
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: _color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 13, color: _color),
          const SizedBox(width: 4),
          Text(_label,
              style: TextStyle(
                color: _color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              )),
        ],
      ),
    );
  }
}
