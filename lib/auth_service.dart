import 'package:firebase_auth/firebase_auth.dart';
String authErrorMessage(FirebaseAuthException error) {
  switch (error.code) {
    case 'invalid-email':
      return 'Enter a valid email address.';
    case 'weak-password':
      return 'Choose a stronger password that meets the password policy.';
    case 'invalid-credential':
    case 'invalid-login-credentials':
    case 'wrong-password':
    case 'user-not-found':
      return 'Unable to verify your credentials. Check them and try again.';
    case 'email-already-in-use':
      return 'Unable to register with these details. Try signing in.';
    case 'too-many-requests':
      return 'Too many attempts. Please wait before trying again.';
    case 'network-request-failed':
      return 'Check your internet connection and try again.';
    case 'requires-recent-login':
      return 'Please sign out, sign in again, and retry.';
    default:
      return 'The request could not be completed. Please try again.';
  }
}
class AuthService {
    final FirebaseAuth _auth = FirebaseAuth.instance;

    Future<UserCredential> register(String email, String password) {
        return _auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
        );
    }

    Future<UserCredential> signIn(String email, String password) {
        return _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
        );
    }

    Future<void> signOut() {
        return _auth.signOut();
    }

    late final Stream<User?> authStateChanges = _auth.authStateChanges();

    Future<void> changePassword(String newPassword) async {
        final user = _auth.currentUser;
        if (user == null) {
            throw StateError('A signed-in user is required to change a password.');
        }
        await user.updatePassword(newPassword);
    }
    Future<void> changePasswordWithRecovery(
      String newPassword,
      String currentPassword,
    ) async {
      try {
        await changePassword(newPassword);
      } on FirebaseAuthException catch (error) {
        if (error.code != 'requires-recent-login') rethrow;

        final user = currentUser;
        if (user == null || user.email == null) {
          throw StateError('Please sign in again.');
        }

        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );

        await user.reauthenticateWithCredential(credential);
        await changePassword(newPassword);
      }
    }

    User? get currentUser => _auth.currentUser;
}