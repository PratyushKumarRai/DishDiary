import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/drive.file',
      'https://www.googleapis.com/auth/drive.appdata',
    ],
  );

  GoogleSignInAccount? _currentUser;

  GoogleSignInAccount? get currentUser => _currentUser;

  Future<bool> signIn() async {
    try {
      _currentUser = await _googleSignIn.signIn();
      return _currentUser != null;
    } catch (error) {
      print('Google Sign-In error: $error');
      return false;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
  }

  Future<bool> isSignedIn() async {
    _currentUser = await _googleSignIn.currentUser;
    return _currentUser != null;
  }

  Future<GoogleSignInAccount?> getCurrentAccount() async {
    // Try to get current user
    _currentUser = await _googleSignIn.currentUser;
    
    // If null, try to sign in silently
    if (_currentUser == null) {
      _currentUser = await _googleSignIn.signInSilently();
    }
    
    return _currentUser;
  }

  String? get userEmail => _currentUser?.email;
  String? get userName => _currentUser?.displayName;
  String? get userId => _currentUser?.id;
}
