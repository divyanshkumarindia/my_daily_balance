import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Stream auth state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
  // Sign Up with Email
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
      data: fullName != null ? {'full_name': fullName} : null,
    );
  }

  // Sign In with Email
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Use the Web Client ID you generated in Google Cloud:
  static const String kWebClientId =
      '524174187471-p6lib92th7u9tu8po0dn2loatu9bnosj.apps.googleusercontent.com';
  // your Android ID
  static const String kAndroidClientId =
      '524174187471-ihpc8l17uiuti2eo0psbco3vh2h6o3ag.apps.googleusercontent.com';

  // Sign In with Google
  Future<AuthResponse> signInWithGoogle() async {
    try {
      // Configure GoogleSignIn based on the platform
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: kWebClientId, // Use clientId for all platforms

        // **REMOVE or comment out the serverClientId line**
        // serverClientId: kAndroidClientId, // This causes the error on Web
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Google Sign-In was cancelled');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null) {
        throw Exception('No Access Token found.');
      }

      // Exchange the tokens for a Supabase session
      return await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken!,
        accessToken: accessToken,
      );
    } catch (e) {
      print("Supabase Google Sign-In Error: $e");
      rethrow;
    }
  }

  // Reset Password
  Future<void> resetPassword({required String email}) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  // Sign Out
  Future<void> signOut() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    try {
      await googleSignIn.signOut();
    } catch (_) {}
    await _supabase.auth.signOut();
  }
}
