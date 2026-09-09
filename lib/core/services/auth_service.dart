import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  FirebaseAuth get _auth => FirebaseAuth.instance;

  User? get currentUser => Firebase.apps.isNotEmpty ? _auth.currentUser : null;
  Stream<User?> get authStateChanges =>
      Firebase.apps.isNotEmpty ? _auth.authStateChanges() : const Stream.empty();

  String? _verificationId;
  int? _resendToken;

  String? get currentVerificationId => _verificationId;

  Future<void> sendPhoneOtp({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String errorMessage) onError,
    required VoidCallback onAutoVerified,
  }) async {
    if (Firebase.apps.isEmpty) {
      debugPrint('AuthService: Firebase not initialized - running in test mode');
      _verificationId = 'test-verification-id';
      onCodeSent(_verificationId!);
      return;
    }
    try {
      debugPrint('AuthService: Requesting phone verification for $phoneNumber');
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          debugPrint('AuthService: Auto-verification completed');
          try {
            await _auth.signInWithCredential(credential);
            onAutoVerified();
          } catch (e) {
            onError(e.toString());
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint('AuthService: Firebase verification failed: [${e.code}] ${e.message}');
          String message = '[${e.code}] ${e.message ?? 'Verification failed'}';
          String rawMessage = e.message ?? '';
          if (rawMessage.contains('region enabled') || rawMessage.contains('17006')) {
            message = 'Firebase has blocked SMS to India (+91) under SMS Region Policy.\n\nFix: Go to Firebase Console > Authentication > Settings tab > SMS Region Policy and allow India (+91).';
          } else if (e.code == 'invalid-phone-number') {
            message = 'The provided phone number is not valid. Please enter a 10-digit number.';
          } else if (e.code == 'too-many-requests') {
            message = 'Too many requests. Please wait a few minutes before trying again.';
          } else if (e.code == 'quota-exceeded') {
            message = 'Firebase daily SMS quota exceeded for this project. Please configure test phone numbers in Firebase Console.';
          } else if (e.code == 'operation-not-allowed') {
            message = 'Phone Auth is disabled in Firebase Console. Please go to Firebase Console > Authentication > Sign-in method and enable "Phone".';
          } else if (e.code == 'app-not-authorized') {
            message = 'App not authorized. Please make sure SHA-1 and SHA-256 are added to Firebase Console.';
          } else if (e.code == 'sms-quota-exceeded' || e.code == 'blocked') {
            message = 'SMS sending blocked by Firebase SMS Region Policy. Please allow India (+91) under Firebase Console > Authentication > Settings > SMS Region Policy.';
          }
          onError(message);
        },
        codeSent: (String verificationId, int? resendToken) {
          debugPrint('AuthService: OTP codeSent with verificationId: $verificationId');
          _verificationId = verificationId;
          _resendToken = resendToken;
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint('AuthService: Auto retrieval timeout for $verificationId');
          _verificationId = verificationId;
        },
        forceResendingToken: _resendToken,
      );
    } catch (e) {
      debugPrint('AuthService: verifyPhoneNumber unexpected exception: $e');
      onError(e.toString());
    }
  }

  Future<UserCredential?> verifyOtp({
    required String smsCode,
    String? verificationId,
  }) async {
    if (Firebase.apps.isEmpty) {
      debugPrint('AuthService: Firebase not initialized - running in test mode');
      return null;
    }
    final vId = verificationId ?? _verificationId;
    if (vId == null) {
      throw Exception('Verification ID is missing. Please click Resend OTP.');
    }
    final credential = PhoneAuthProvider.credential(
      verificationId: vId,
      smsCode: smsCode,
    );
    return await _auth.signInWithCredential(credential);
  }

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await _auth.signOut();
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}
  }

  Future<UserCredential?> signInWithGoogle() async {
    if (Firebase.apps.isEmpty) {
      debugPrint('AuthService: Running in mock/test mode');
      return null;
    }
    try {
      debugPrint('AuthService: Launching Google Sign-In...');
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint('AuthService: Google Sign-In was cancelled by user');
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      debugPrint('AuthService: Signing into Firebase with Google credentials...');
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      debugPrint('AuthService: Firebase Google sign-in failed: [${e.code}] ${e.message}');
      String message = '[${e.code}] ${e.message ?? 'Google Sign-In failed'}';
      if (e.code == 'operation-not-allowed') {
        message = 'Google Sign-In is not enabled in Firebase Console. Please enable "Google" under Authentication > Sign-in method.';
      } else if (e.code == 'account-exists-with-different-credential') {
        message = 'An account already exists with the same email address.';
      }
      throw Exception(message);
    } catch (e) {
      debugPrint('AuthService: Google Sign-In error: $e');
      rethrow;
    }
  }
}
