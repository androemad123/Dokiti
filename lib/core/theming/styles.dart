import "package:flutter/material.dart";
import 'package:flutter_screenutil/flutter_screenutil.dart';


class MyTextStyle {
  static TextStyle font16SemiBold(BuildContext context) {
    return TextStyle(
      fontSize: 16.sp,
      fontFamily: "Poppins",
      fontWeight: FontWeight.w600,
      color: Theme.of(context).colorScheme.primary, // Dynamic theme color
    );
  }
}