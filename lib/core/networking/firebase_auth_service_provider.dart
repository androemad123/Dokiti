import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';
import 'firebase_auth_service.dart';

// Create a provider for our FirebaseAuthService
final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});

// Auth state provider
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthServiceProvider).authStateChanges;
});

// AppUser provider that converts Firebase User to our AppUser model
final appUserProvider = Provider<AppUser?>((ref) {
  final user = ref.watch(authStateProvider).value;
  return AppUser.fromFirebaseUserNullable(user);
});

// Provider for auth operations
final authProvider = Provider<AuthProvider>((ref) {
  return AuthProvider(ref);
});

class AuthProvider {
  final Ref ref;

  AuthProvider(this.ref);

  FirebaseAuthService get _auth => ref.read(firebaseAuthServiceProvider);

  // Sign up with email and password
  Future<AppUser?> signUpWithEmailAndPassword(
      String email, String password, String displayName) async {
    try {
      final user = await _auth.signUpWithEmailAndPassword(
          email, password, displayName);
      return AppUser.fromFirebaseUserNullable(user);
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with email and password
  Future<AppUser?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final user = await _auth.signInWithEmailAndPassword(email, password);
      return AppUser.fromFirebaseUserNullable(user);
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with Google
  Future<AppUser?> signInWithGoogle() async {
    try {
      final user = await _auth.signInWithGoogle();
      return AppUser.fromFirebaseUserNullable(user);
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Other methods can be added here following the same pattern
  // (password reset, email verification, etc.)
}