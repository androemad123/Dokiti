import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData? prefixIcon;
  final bool isSecuredField;
  final IconData? suffixIconVisible;
  final IconData? suffixIconHidden;
  final bool? obscureText;
  final Function()? onSuffixIconPressed;
  final Function()? onTap;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;

  const AppTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.isSecuredField,
    this.onTap,
    this.prefixIcon,
    this.obscureText,
    this.suffixIconVisible,
    this.suffixIconHidden,
    this.onSuffixIconPressed,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        onTap: onTap,
        validator: validator,
        controller: controller,
        obscureText: isSecuredField ? obscureText! : false,
        decoration: InputDecoration(
          filled: true,
          fillColor: Theme.of(context).appBarTheme.backgroundColor,
          hintText: hintText,
          hintStyle: TextStyle(
            color: Theme.of(context).hintColor,
            fontFamily: "Poppins",
          ),
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          suffixIcon: isSecuredField
              ? IconButton(
            onPressed: onSuffixIconPressed,
            icon: Icon(
              obscureText! ? suffixIconHidden : suffixIconVisible,
            ),
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
        keyboardType: keyboardType,
        onChanged: onChanged,
      ),
    );
  }
}
