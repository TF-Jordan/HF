import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// A styled section title with an optional trailing widget.
class SectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.icon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final c = HarmonyColors.of(context);
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, color: c.primary, size: 20),
          const SizedBox(width: 10),
        ],
        Text(
          title,
          style: TextStyle(
            color: c.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}
