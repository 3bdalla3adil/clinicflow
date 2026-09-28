import 'package:flutter/material.dart';
import '../../app/theme/app_dimensions.dart';

enum AppButtonVariant { primary, outlined, text, destructive }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final double? height;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final child = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: variant == AppButtonVariant.primary
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.primary,
            ),
          )
        : icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: AppDimensions.iconMd),
                  const SizedBox(width: AppDimensions.spaceS),
                  Text(label),
                ],
              )
            : Text(label);

    final sz = isFullWidth
        ? Size.fromHeight(height ?? AppDimensions.buttonHeight)
        : null;

    switch (variant) {
      case AppButtonVariant.outlined:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: sz != null
              ? OutlinedButton.styleFrom(minimumSize: sz)
              : null,
          child: child,
        );
      case AppButtonVariant.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          child: child,
        );
      case AppButtonVariant.destructive:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
            minimumSize: sz,
          ),
          child: child,
        );
      case AppButtonVariant.primary:
      default:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: sz != null
              ? ElevatedButton.styleFrom(minimumSize: sz)
              : null,
          child: child,
        );
    }
  }
}
