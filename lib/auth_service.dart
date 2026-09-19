class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  String? token;

  bool get isAuthenticated => token != null;

  void setToken(String t) {
    token = t;
  }
  
  void clearToken() {
    token = null;
  }
}

final authService = AuthService();

