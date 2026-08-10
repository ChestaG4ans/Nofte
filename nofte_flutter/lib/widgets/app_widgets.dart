import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';
import '../providers/app_state.dart';

/// NoFTe Logo Widget
class Noftelogo extends StatelessWidget {
  final double size;
  final String variant; // 'primary', 'teal', 'dark', 'icon'

  const Noftelogo({
    super.key,
    this.size = 48,
    this.variant = 'primary',
  });

  @override
  Widget build(BuildContext context) {
    String assetPath;
    switch (variant) {
      case 'teal':
        assetPath = 'assets/logo/logo_teal.svg';
        break;
      case 'dark':
        assetPath = 'assets/logo/logo_dark.svg';
        break;
      case 'icon':
        assetPath = 'assets/logo/logo_icon.svg';
        break;
      default:
        assetPath = 'assets/logo/logo_primary.svg';
    }

    return SvgPicture.asset(
      assetPath,
      width: size,
      height: size,
    );
  }
}

/// Status Pill Widget
class StatusPill extends StatelessWidget {
  final String label;
  final StatusType type;

  const StatusPill({
    super.key,
    required this.label,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    switch (type) {
      case StatusType.fresh:
        bgColor = AppColors.freshBg;
        textColor = AppColors.freshText;
        break;
      case StatusType.soon:
        bgColor = AppColors.soonBg;
        textColor = AppColors.soonText;
        break;
      case StatusType.critical:
        bgColor = AppColors.criticalBg;
        textColor = AppColors.criticalText;
        break;
      case StatusType.purple:
        bgColor = AppColors.purpleBg;
        textColor = AppColors.purpleText;
        break;
      case StatusType.blue:
        bgColor = AppColors.blueBg;
        textColor = AppColors.blueText;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
}

/// Custom Chip Widget
class CustomChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const CustomChip({
    super.key,
    required this.label,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: isActive ? null : Border.all(color: AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isActive ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// Food Item Card Widget
class FoodItemCard extends StatelessWidget {
  final String name;
  final String emoji;
  final int daysLeft;
  final StatusType status;
  final VoidCallback? onTap;

  const FoodItemCard({
    super.key,
    required this.name,
    required this.emoji,
    required this.daysLeft,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color statusBg;
    Color statusText;
    String statusLabel;

    switch (status) {
      case StatusType.fresh:
        statusBg = AppColors.freshBg;
        statusText = AppColors.freshText;
        statusLabel = 'Segar';
        break;
      case StatusType.soon:
        statusBg = AppColors.soonBg;
        statusText = AppColors.soonText;
        statusLabel = 'Segera';
        break;
      case StatusType.critical:
        statusBg = AppColors.criticalBg;
        statusText = AppColors.criticalText;
        statusLabel = 'Kritis!';
        break;
      case StatusType.purple:
        statusBg = AppColors.purpleBg;
        statusText = AppColors.purpleText;
        statusLabel = 'AI';
        break;
      case StatusType.blue:
        statusBg = AppColors.blueBg;
        statusText = AppColors.blueText;
        statusLabel = 'Info';
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              name,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              statusLabel,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: statusText,
              ),
            ),
            Text(
              daysLeft == 0 ? 'Hari ini' : '$daysLeft hari',
              style: const TextStyle(
                fontSize: 8,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Score Card Widget
class ScoreCard extends StatelessWidget {
  final int score;
  final int maxScore;
  final String subtitle;
  final double change;

  const ScoreCard({
    super.key,
    required this.score,
    this.maxScore = 100,
    required this.subtitle,
    this.change = 0,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = score / maxScore;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, Color(0xFF154360)],
        ),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Colors.white10, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SKOR DAPUR',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.white54,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '$score ',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(
                          text: '/ $maxScore',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white38,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Color(0x26FFFFFF), width: 0.5),
                ),
                child: Text(
                  '+$change minggu ini',
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppColors.teal,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.teal),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 9,
              color: Colors.white38,
            ),
          ),
        ],
      ),
    );
  }
}

/// Quick Action Button
class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bgColor;
  final Color iconColor;
  final VoidCallback? onTap;

  const QuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 17),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Notification Badge
class NotificationBadge extends StatelessWidget {
  final int count;
  final Widget child;

  const NotificationBadge({
    super.key,
    required this.count,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (count > 0)
          Positioned(
            top: -3,
            right: -3,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.danger,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }
}
