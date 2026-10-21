import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Filter pill sized to its own text.
///
/// Material's ChoiceChip clips longer labels here ("Trio Showdown" came out as
/// "Trio Showdow"), so the filter rows use this instead: plain padding, no
/// internal constraints, and the game's pressed-button lip when selected.
class FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const FilterPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.surface,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
          child: Text(
            label,
            softWrap: false,
            overflow: TextOverflow.visible,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: selected
                  ? const Color(0xFF2B1A00)
                  : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
