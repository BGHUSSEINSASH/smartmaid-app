import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/theme/adaptive.dart';
import '../../core/theme/app_theme.dart';

class AppImage extends StatelessWidget {
  final String url;
  final double? width;
  final double height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const AppImage({
    super.key,
    required this.url,
    this.width,
    this.height = 84,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final image = CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, _) => Container(
        width: width,
        height: height,
        color: context.isDark ? Colors.white10 : const Color(0xFFE9EDF7),
      ),
      errorWidget: (_, _, _) => Container(
        width: width,
        height: height,
        color: context.isDark ? Colors.white10 : const Color(0xFFE9EDF7),
        child: Icon(Icons.person_rounded,
            size: height * 0.45,
            color: context.isDark ? Colors.white38 : AppColors.muted),
      ),
    );
    if (borderRadius == null) return image;
    return ClipRRect(borderRadius: borderRadius!, child: image);
  }
}

class AppAvatar extends StatelessWidget {
  final String url;
  final double radius;

  const AppAvatar({super.key, required this.url, this.radius = 24});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor:
          context.isDark ? Colors.white10 : const Color(0xFFE9EDF7),
      backgroundImage: NetworkImage(url),
    );
  }
}
