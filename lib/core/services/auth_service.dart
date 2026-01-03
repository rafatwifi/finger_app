class AuthService {
  String? _currentUserId;

  String? get currentUserId => _currentUserId;

  void signInMock(String userId) {
    _currentUserId = userId;
  }

  void signOut() {
    _currentUserId = null;
  }
}
