import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants.dart';

class ComboIndicator extends StatelessWidget {
  final int combo;

  const ComboIndicator({super.key, required this.combo});

  @override
  Widget build(BuildContext context) {
    if (combo < 2) return const SizedBox.shrink();

    Color color;
    String text;
    IconData icon;

    if (combo >= 10) {
      color = AppColors.accent;
      text = 'MEGA COMBO x$combo';
      icon = Icons.whatshot;
    } else if (combo >= 5) {
      color = AppColors.warning;
      text = 'SUPER COMBO x$combo';
      icon = Icons.local_fire_department;
    } else {
      color = AppColors.success;
      text = 'COMBO x$combo';
      icon = Icons.flash_on;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingL,
        vertical: AppDimensions.paddingM,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusL),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: AppDimensions.paddingS),
          Text(
            text,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    )
        .animate(key: ValueKey(combo))
        .scale(begin: const Offset(0.8, 0.8), duration: 200.ms, curve: Curves.easeOut)
        .fadeIn(duration: 150.ms)
        .then()
        .shimmer(duration: 400.ms, color: Colors.white.withAlpha(77));
  }
}
