import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';

class PasswordStrengthBar extends StatelessWidget {
  final int score; // 0 to 4
  final String label;

  const PasswordStrengthBar({
    super.key,
    required this.score,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    Color activeColor;
    if (score <= 1) {
      activeColor = AppColors.strengthWeak;
    } else if (score <= 2) {
      activeColor = AppColors.strengthMedium;
    } else {
      activeColor = AppColors.strengthStrong;
    }

    return Row(
      children: [
        // 4 Segment Bars
        for (int i = 0; i < 4; i++) ...[
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 4,
              decoration: BoxDecoration(
                color: i < score ? activeColor : AppColors.strengthInactive,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          if (i < 3) const SizedBox(width: 6),
        ],
        const SizedBox(width: 12),
        // Strength Label (e.g. "Kuat")
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 250),
          style: AppTextStyles.strengthLabel.copyWith(
            color: score > 0 ? activeColor : AppColors.textMuted,
          ),
          child: Text(score == 0 ? '' : label),
        ),
      ],
    );
  }
}
