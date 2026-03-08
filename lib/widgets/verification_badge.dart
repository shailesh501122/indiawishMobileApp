import 'package:flutter/material.dart';
import '../core/constants.dart';

/// A small badge chip showing the user's verification level.
class VerificationBadge extends StatelessWidget {
  final String level; // 'unverified', 'phone', 'id', 'top_seller'
  final bool compact;

  const VerificationBadge({super.key, required this.level, this.compact = false});

  @override
  Widget build(BuildContext context) {
    if (level == 'unverified') return const SizedBox.shrink();

    final config = _config(level);
    if (config == null) return const SizedBox.shrink();

    if (compact) {
      return Tooltip(
        message: config['label'] as String,
        child: Icon(config['icon'] as IconData, color: config['color'] as Color, size: 14),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: (config['color'] as Color).withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: (config['color'] as Color).withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config['icon'] as IconData, color: config['color'] as Color, size: 12),
          const SizedBox(width: 3),
          Text(
            config['label'] as String,
            style: TextStyle(
              color: config['color'] as Color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic>? _config(String level) {
    switch (level) {
      case 'phone':
        return {'icon': Icons.phone_rounded, 'color': Colors.blue, 'label': 'Phone Verified'};
      case 'id':
        return {'icon': Icons.verified_user_rounded, 'color': Colors.green, 'label': 'ID Verified'};
      case 'top_seller':
        return {'icon': Icons.workspace_premium_rounded, 'color': AppColors.featured, 'label': 'Top Seller'};
      default:
        return null;
    }
  }
}
