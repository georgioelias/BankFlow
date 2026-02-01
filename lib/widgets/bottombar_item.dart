import 'package:flutter/material.dart';
import '../theme/colors.dart';

class BottomBarItem extends StatelessWidget {
  const BottomBarItem({
    super.key,
    required this.icon,
    required this.label,
    this.color = AppColor.inActiveIcon,
    this.activeColor = AppColor.primary,
    this.isActive = false,
    this.isNotified = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color activeColor;
  final bool isNotified;
  final bool isActive;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          isNotified ? _buildIconNotified() : _buildIcon(),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 4),
            _buildLabel(),
          ],
        ],
      ),
    );
  }

  Widget _buildIconNotified() {
    return Stack(
      children: <Widget>[
        _buildIcon(),
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildIcon() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isActive ? activeColor.withAlpha(26) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        size: 24,
        color: isActive ? activeColor : activeColor.withAlpha(102),
      ),
    );
  }

  Widget _buildLabel() {
    return Text(
      label,
      style: TextStyle(
        fontSize: 10,
        fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
        color: isActive ? activeColor : activeColor.withAlpha(128),
      ),
    );
  }
}
