import 'package:flutter/material.dart';
import 'avatar_image.dart';

class UserBox extends StatelessWidget {
  const UserBox({
    super.key,
    required this.user,
    this.isSVG = false,
    this.width = 55,
    this.height = 55,
    this.onTap,
  });

  final Map<String, dynamic> user;
  final double width;
  final double height;
  final bool isSVG;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AvatarImage(
            user["image"] ?? '',
            isSVG: isSVG,
            width: width,
            height: height,
          ),
          const SizedBox(height: 8),
          Text(
            user["fname"] ?? '',
            style: const TextStyle(fontWeight: FontWeight.w500),
          )
        ],
      ),
    );
  }
}
