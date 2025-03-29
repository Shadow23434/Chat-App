import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  // Log in
  Future<AuthResponse> logInWithEmailPassword(
    String email,
    String password,
  ) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign up
  Future<AuthResponse> signUpWithEmailPassword(
    String email,
    String password,
  ) async {
    return await _client.auth.signUp(email: email, password: password);
  }

  // Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Get user
  String? getCurrentUserID() {
    final session = _client.auth.currentSession;
    final user = session?.user;
    return user?.id;
  }

  // Get user email
  String? getCurrentUserEmail() {
    final session = _client.auth.currentSession;
    final user = session?.user;
    return user?.email;
  }
}
