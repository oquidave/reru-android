import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final (bg, text, label) = _resolve(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: text,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  static (Color bg, Color text, String label) _resolve(String status) {
    return switch (status.toLowerCase()) {
      'active'    => (AppColors.successBg, AppColors.successText, 'Active'),
      'suspended' => (AppColors.errorBg,   AppColors.errorText,   'Suspended'),
      'completed' => (AppColors.successBg, AppColors.successText, 'Collected'),
      'scheduled' => (AppColors.infoBg,    AppColors.infoText,    'Scheduled'),
      'missed'    => (AppColors.errorBg,   AppColors.errorText,   'Missed'),
      'paid'      => (AppColors.successBg, AppColors.successText, 'Paid'),
      'pending'   => (AppColors.warningBg, AppColors.warningText, 'Pending'),
      'overdue'   => (AppColors.errorBg,   AppColors.errorText,   'Overdue'),
      _           => (AppColors.grayBg,    AppColors.grayText,    status),
    };
  }
}
