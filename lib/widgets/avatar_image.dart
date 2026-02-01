import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../theme/colors.dart';

class AvatarImage extends StatelessWidget {
  const AvatarImage(
    this.name, {
    super.key,
    this.width = 100,
    this.height = 100,
    this.bgColor,
    this.borderWidth = 0,
    this.borderColor,
    this.trBackground = false,
    this.isSVG = true,
    this.radius = 50,
  });

  final String name;
  final double width;
  final double height;
  final double borderWidth;
  final Color? borderColor;
  final Color? bgColor;
  final bool trBackground;
  final bool isSVG;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return isSVG ? _buildSVG(context) : _buildNetworkImage(context);
  }

  Widget _buildNetworkImage(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor ?? Theme.of(context).cardColor,
          width: borderWidth,
        ),
        color: bgColor,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: AppColor.shadowColor.withAlpha(26),
            spreadRadius: 1,
            blurRadius: 1,
            offset: const Offset(1, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.network(
          name,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey.shade300,
              child: Icon(
                Icons.person,
                size: width * 0.5,
                color: Colors.grey.shade600,
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: Colors.grey.shade200,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSVG(BuildContext context) {
    // Generate a simple avatar based on the name
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final color = _getColorFromString(name);
    
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor ?? Theme.of(context).cardColor,
          width: borderWidth,
        ),
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: Colors.white,
            fontSize: width * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Color _getColorFromString(String str) {
    final colors = [
      AppColor.primary,
      AppColor.appBgColorPrimary,
      AppColor.appBgColorSecondary,
      AppColor.green,
      AppColor.yellow,
      AppColor.purple,
      AppColor.pink,
    ];
    final index = str.hashCode.abs() % colors.length;
    return colors[index];
  }
}
