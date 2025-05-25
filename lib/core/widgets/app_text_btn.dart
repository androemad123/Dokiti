import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTextBtn extends StatelessWidget {
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderWidth;
  final double? horizontalPadding;
  final double? verticalPadding;
  final double? buttonWidth;
  final double? buttonHeight;
  final String buttonText;
  final TextStyle? textStyle;
  final VoidCallback onPressed;
  final bool isPrimary; // New parameter to use primary color
  final bool isOutlined; // New parameter for outlined style

  const AppTextBtn({
    super.key,
    this.borderRadius,
    this.backgroundColor,
    this.horizontalPadding,
    this.verticalPadding,
    this.buttonWidth,
    this.buttonHeight,
    required this.buttonText,
    this.textStyle,
    required this.onPressed,
    this.borderColor,
    this.borderWidth = 1.0,
    this.isPrimary = false,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine colors based on theme and parameters
    final Color bgColor = isOutlined
        ? Colors.transparent
        : (isPrimary
        ? colorScheme.primary
        : (backgroundColor ?? colorScheme.surface));

    final Color textColor = isOutlined
        ? (isPrimary ? colorScheme.primary : colorScheme.onSurface)
        : (isPrimary ? colorScheme.onPrimary : colorScheme.onSurface);

    final Color btnBorderColor = borderColor ??
        (isPrimary ? colorScheme.primary : colorScheme.outline);

    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 10.0.r),
            side: BorderSide(
              color: isOutlined ? btnBorderColor : Colors.transparent,
              width: isOutlined ? (borderWidth ?? 1.0) : 0,
            ),
          ),
        ),
        backgroundColor: WidgetStateProperty.resolveWith<Color>(
              (states) {
            if (states.contains(WidgetState.disabled)) {
              return colorScheme.onSurface.withOpacity(0.12);
            }
            if (states.contains(WidgetState.pressed)) {
              return bgColor.withOpacity(0.8);
            }
            if (states.contains(WidgetState.hovered)) {
              return bgColor.withOpacity(0.9);
            }
            return bgColor;
          },
        ),
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        padding: WidgetStateProperty.all<EdgeInsets>(
          EdgeInsets.symmetric(
            horizontal: horizontalPadding ?? 12.w,
            vertical: verticalPadding ?? 14.h,
          ),
        ),
        fixedSize: WidgetStateProperty.all(
          Size(buttonWidth ?? 301.w, buttonHeight ?? 56.h),
        ),
        elevation: WidgetStateProperty.all(0),
      ),
      child: Text(
        buttonText,
        style: (textStyle ?? theme.textTheme.labelLarge)?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}