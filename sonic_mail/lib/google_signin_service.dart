import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  Future<Map<String, String?>> signInAndGetAuthHeaders() async {
    try {
      await _googleSignIn.signIn();
      final currentUser = _googleSignIn.currentUser;
      if (currentUser != null) {
        final Map<String, String> authHeaders = await currentUser.authHeaders;
        final String? accessToken = authHeaders['Authorization'];
        final userId = currentUser.id;
        return {'accessToken': accessToken, 'userId': userId};
      } else {
        throw Exception('User is not signed in');
      }
    } catch (error) {
      throw Exception('Failed to sign in with Google: $error');
    }
  }
}
