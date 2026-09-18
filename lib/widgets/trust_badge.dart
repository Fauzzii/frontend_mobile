import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';

class TrustBadge extends StatelessWidget {
  const TrustBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.verified_user_rounded,
          size: 16,
          color: AppColors.success,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            'Transaksi aman dan terverifikasi 100%',
            style: AppTextStyles.trustBadgeText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
