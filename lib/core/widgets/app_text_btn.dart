import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTextBtn extends StatelessWidget {
  final double? borderRadius;
  final Color? backGroundColor;
  final Color? borderColor;  // New border color parameter
  final double? borderWidth; // New border width parameter
  final double? horizontalPadding;
  final double? verticalPadding;
  final double? buttonWidth;
  final double? buttonHeight;
  final String buttonText;
  final TextStyle textStyle;
  final VoidCallback onPressed;

  const AppTextBtn({
    super.key,
    this.borderRadius,
    this.backGroundColor,
    this.horizontalPadding,
    this.verticalPadding,
    this.buttonWidth,
    this.buttonHeight,
    required this.buttonText,
    required this.textStyle,
    required this.onPressed,
    this.borderColor,    // Add to constructor
    this.borderWidth = 1.0, // Default border width
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 10.0),
            // Add border configuration
            side: BorderSide(
              color: borderColor ?? Colors.transparent,
              width: borderWidth ?? 1.0,
            ),
          ),
        ),
        backgroundColor: WidgetStatePropertyAll(
          backGroundColor ?? Theme.of(context).colorScheme.onPrimary,
        ),
        padding: WidgetStateProperty.all<EdgeInsets>(
          EdgeInsets.symmetric(
            horizontal: horizontalPadding ?? 12.w,
            vertical: verticalPadding ?? 14.h,
          ),
        ),
        fixedSize: WidgetStateProperty.all(
          Size(buttonWidth ?? 301, buttonHeight ?? 56.h),
        ),
        // Add visual feedback for pressed state
        overlayColor: WidgetStateProperty.resolveWith<Color>(
          (states) {
            if (states.contains(WidgetState.pressed)) {
              return (borderColor ?? Theme.of(context).colorScheme.onPrimary).withOpacity(0.1);
            }
            return Colors.transparent;
          },
        ),
      ),
      child: Text(
        buttonText,
        style: textStyle,
      ),
    );
  }
}