// lib/widgets/CategoryFilterBar.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Theme/app_theme.dart';
import '../provider/app_provider.dart';

class CategoryFilterBar extends StatelessWidget {
  /// Currently selected category_id, or null for "All"
  final int? selectedCategoryId;

  /// Called with the tapped category_id (null = All)
  final ValueChanged<int?> onSelected;

  const CategoryFilterBar({
    super.key,
    required this.selectedCategoryId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<AppProvider>().skillsCategories;

    // Show shimmer-style placeholder while loading
    if (categories.isEmpty) {
      return SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 5,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, __) => Container(
            width: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        // +1 for the "All" chip at the front
        itemCount: categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) {
          // ── "All" chip ────────────────────────────────────────
          if (i == 0) {
            final selected = selectedCategoryId == null;
            return _CategoryChip(
              label: 'All',
              selected: selected,
              onTap: () => onSelected(null),
            );
          }

          // ── Category chip ─────────────────────────────────────
          final cat = categories[i - 1];
          final id = (cat['category_id'] as num?)?.toInt();
          final name = cat['category_name']?.toString() ?? '';
          final selected = selectedCategoryId == id;

          return _CategoryChip(
            label: name,
            selected: selected,
            onTap: () => onSelected(selected ? null : id),
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppTheme.primary : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
