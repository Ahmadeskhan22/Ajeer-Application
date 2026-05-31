import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../provider/app_provider.dart';
import '../models/SeekerProfile.dart';
import '../models/Job.dart';
import '../Theme/app_theme.dart';
import '../Translations/translations.dart';

//  3. GRADIENT BUTTON (GradBtn)
//
//  Primary CTA button with brand gradient background.
//
//  label     — button text (required)
//  icon      — optional leading icon
//  onPressed — null disables the button
//  fullWidth — true (default) = stretches to parent width
//
//  Used for: "Get Started", "Save Profile", "Find My Matches"

class GradBtn extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool fullWidth;

  const GradBtn({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.fullWidth = true,
  });
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      width: fullWidth ? double.infinity : null,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
            child: Row(
              mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
