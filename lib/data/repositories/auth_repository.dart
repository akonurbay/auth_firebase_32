import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<void> signUp({required String email, required String password}) async {
    await _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signIn({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<UserCredential> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) throw Exception('Google Sign-In cancelled');
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return await _auth.signInWithCredential(credential);
  }

  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    await _auth.currentUser?.updateDisplayName(displayName);
    await _auth.currentUser?.updatePhotoURL(photoURL);
    await _auth.currentUser?.reload();
  }

  String getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found': return 'Пользователь не найден';
      case 'wrong-password': return 'Неверный пароль';
      case 'email-already-in-use': return 'Email уже используется';
      case 'weak-password': return 'Слабый пароль (мин. 6 символов)';
      case 'invalid-email': return 'Неверный формат email';
      default: return 'Ошибка: $code';
    }
  }
}