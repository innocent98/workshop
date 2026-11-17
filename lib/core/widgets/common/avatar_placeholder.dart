import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_colors.dart';

/// Initials for a display name: 'Ada Obi' -> 'AO', 'Ada' -> 'A', '' -> ''.
String avatarInitials(String? name) {
  final parts = (name ?? '')
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '';
  final first = String.fromCharCode(parts.first.runes.first);
  if (parts.length == 1) return first.toUpperCase();
  final last = String.fromCharCode(parts.last.runes.first);
  return (first + last).toUpperCase();
}

/// Circle in a light teal tint showing the user's initials, or a person icon
/// when no name is known. Replaces the shared stock photo fallback.
class AvatarPlaceholder extends StatelessWidget {
  final String? name;
  final double radius;

  const AvatarPlaceholder({super.key, this.name, this.radius = 20});

  @override
  Widget build(BuildContext context) {
    final initials = avatarInitials(name);
    final r = radius.r;
    return Container(
      width: r * 2,
      height: r * 2,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withValues(alpha: 0.12),
      ),
      child: initials.isEmpty
          ? Icon(Icons.person, size: r * 1.1, color: AppColors.primary)
          : Text(
              initials,
              style: TextStyle(
                fontSize: r * 0.8,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
    );
  }
}

/// Circular profile picture. Falls back to [AvatarPlaceholder] when the URL is
/// missing, is not an http(s) URL, or fails to load.
class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double radius;

  const ProfileAvatar({super.key, this.imageUrl, this.name, this.radius = 20});

  bool get _isNetwork {
    final url = imageUrl?.trim() ?? '';
    return url.startsWith('http://') || url.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    final placeholder = AvatarPlaceholder(name: name, radius: radius);
    if (!_isNetwork) return placeholder;
    final size = radius.r * 2;
    return ClipOval(
      child: Image.network(
        imageUrl!.trim(),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => placeholder,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : placeholder,
      ),
    );
  }
}
