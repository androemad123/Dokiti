import 'package:alhy_momken_task/core/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:alhy_momken_task/core/widgets/app_text_btn.dart';
import 'package:alhy_momken_task/core/widgets/app_text_field.dart';

import '../../../core/networking/firebase_auth_service_provider.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // CORRECT way to use ref - through the state class
      await ref.read(authProvider).signUpWithEmailAndPassword(
        emailController.text.trim(),
        passwordController.text.trim(),
        fullNameController.text.trim(),
      );

      await ref.read(firebaseAuthServiceProvider).sendEmailVerification();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Account created! Please verify your email.'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );

      if (mounted) Navigator.pop(context);
      Navigator.pushReplacementNamed(context, Routes.loginScreen);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        minimum: EdgeInsets.only(top: 40.h),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Join with us!",
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  "Register to enjoy our best features",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 50.h),

                // Full Name Field
                AppTextField(
                  controller: fullNameController,
                  hintText: "Full Name",
                  isSecuredField: false,
                  prefixIcon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                // Email Field
                AppTextField(
                  controller: emailController,
                  hintText: "Email Address",
                  isSecuredField: false,
                  prefixIcon: Icons.email,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                // Phone Field (optional)
                AppTextField(
                  controller: phoneController,
                  hintText: "Phone Number",
                  isSecuredField: false,
                  prefixIcon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value != null && value.isNotEmpty && !RegExp(r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$').hasMatch(value)) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                // Password Field
                AppTextField(
                  controller: passwordController,
                  hintText: "Password",
                  isSecuredField: true,
                  obscureText: obscurePassword,
                  prefixIcon: Icons.lock,
                  suffixIconVisible: Icons.visibility,
                  suffixIconHidden: Icons.visibility_off,
                  onSuffixIconPressed: () {
                    setState(() {
                      obscurePassword = !obscurePassword;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                // Confirm Password Field
                AppTextField(
                  controller: confirmPasswordController,
                  hintText: "Confirm Password",
                  isSecuredField: true,
                  obscureText: obscureConfirmPassword,
                  prefixIcon: Icons.lock_outline,
                  suffixIconVisible: Icons.visibility,
                  suffixIconHidden: Icons.visibility_off,
                  onSuffixIconPressed: () {
                    setState(() {
                      obscureConfirmPassword = !obscureConfirmPassword;
                    });
                  },
                  validator: (value) {
                    if (value != passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 30.h),

                // Sign Up Button
                Center(
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : AppTextBtn(
                    buttonWidth: 700.w,
                    buttonText: "Sign Up",
                    isPrimary: true,
                    onPressed: _submitForm,
                  ),
                ),
                SizedBox(height: 20.h),

                // Login Redirect
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, Routes.loginScreen);
                    },
                    child: Text.rich(
                      TextSpan(
                        text: "Already have an account? ",
                        style: theme.textTheme.bodyMedium,
                        children: [
                          TextSpan(
                            text: "Login",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}