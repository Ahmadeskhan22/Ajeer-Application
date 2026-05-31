import 'package:flutter/material.dart';
import '../../Theme/app_theme.dart';

class MetaChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const MetaChip(this.icon, this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppTheme.textMuted),
        const SizedBox(width: 3),
        Text(
          text,
          style: const TextStyle(
            color: AppTheme.textMuted,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
