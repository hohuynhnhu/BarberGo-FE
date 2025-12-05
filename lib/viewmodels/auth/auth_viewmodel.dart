import 'package:barbergofe/core/utils/auth_storage.dart';
import 'package:barbergofe/models/auth/user_model.dart';
import 'package:barbergofe/services/auth_service.dart';
import 'package:flutter/material.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  // ==================== STATE ====================

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  String? _accessToken;
  String? get accessToken => _accessToken;

  String? _userId;
  String? get userId => _userId;

  bool get isAuthenticated => _currentUser != null && _accessToken != null;

  // ==================== INIT ====================

  Future<void> init() async {
    print(' [AUTH VIEWMODEL] Initializing...');

    try {
      final isLoggedIn = await _authService.isAuthenticated();

      if (isLoggedIn) {
        _currentUser = await _authService.getCurrentUser();
        _accessToken = await AuthStorage.getAccessToken();
        _userId = await AuthStorage.getUserId();

        print(' [AUTH VIEWMODEL] User logged in: ${_currentUser?.fullName}');
        notifyListeners();
      } else {
        print('ℹ [AUTH VIEWMODEL] No user logged in');
      }
    } catch (e) {
      print(' [AUTH VIEWMODEL] Init error: $e');
    }
  }

  // ==================== REGISTER ====================

  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    print('🟦 [AUTH VIEWMODEL] Register called');

    _setLoading(true);
    _clearMessages();

    try {
      final response = await _authService.register(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      );

      print('✅ [AUTH VIEWMODEL] Registration successful');

      _setSuccess(response.message);
      _setLoading(false);

      return true;

    } catch (e) {
      print('❌ [AUTH VIEWMODEL] Registration failed: $e');
      _setError(_formatErrorMessage(e));
      _setLoading(false);
      return false;
    }
  }

  // ==================== LOGIN ====================

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    print('🟦 [AUTH VIEWMODEL] Login called');

    _setLoading(true);
    _clearMessages();

    try {
      final response = await _authService.login(
        email: email,
        password: password,
      );

      _currentUser = response.user;
      _accessToken = response.accessToken;
      _userId = response.user.id;

      print('✅ [AUTH VIEWMODEL] Login successful');
      print('   User: ${_currentUser?.fullName}');
      print('   User ID: $_userId');

      _setLoading(false);
      notifyListeners();

      return true;

    } catch (e) {
      print('❌ [AUTH VIEWMODEL] Login failed: $e');
      _setError(_formatErrorMessage(e));
      _setLoading(false);
      return false;
    }
  }

  // ==================== FORGOT PASSWORD ====================

  Future<bool> forgotPassword({required String email}) async {
    print('🟦 [AUTH VIEWMODEL] Forgot password called');

    _setLoading(true);
    _clearMessages();

    try {
      final result = await _authService.forgotPassword(email: email);

      _setSuccess(result['message'] ?? 'Email đặt lại mật khẩu đã được gửi');
      _setLoading(false);
      return true;

    } catch (e) {
      _setError(_formatErrorMessage(e));
      _setLoading(false);
      return false;
    }
  }

  // ==================== RESET PASSWORD ====================

  Future<bool> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    print('🟦 [AUTH VIEWMODEL] Reset password called');

    _setLoading(true);
    _clearMessages();

    try {
      final result = await _authService.resetPassword(
        email: email,
        token: token,
        newPassword: newPassword,
      );

      _setSuccess(result['message'] ?? 'Đặt lại mật khẩu thành công');
      _setLoading(false);
      return true;

    } catch (e) {
      _setError(_formatErrorMessage(e));
      _setLoading(false);
      return false;
    }
  }

  // ==================== RESEND CONFIRMATION ====================

  Future<bool> resendConfirmation({required String email}) async {
    print('🟦 [AUTH VIEWMODEL] Resend confirmation called');

    _setLoading(true);
    _clearMessages();

    try {
      final result = await _authService.resendConfirmation(email: email);

      _setSuccess(result['message'] ?? 'Email xác nhận đã được gửi lại');
      _setLoading(false);
      return true;

    } catch (e) {
      _setError(_formatErrorMessage(e));
      _setLoading(false);
      return false;
    }
  }

  // ==================== LOGOUT ====================

  Future<void> logout() async {
    print('🟦 [AUTH VIEWMODEL] Logout called');

    try {
      await _authService.logout();

      _currentUser = null;
      _accessToken = null;
      _userId = null;
      _clearMessages();

      notifyListeners();

      print('✅ [AUTH VIEWMODEL] Logout successful');

    } catch (e) {
      print('❌ [AUTH VIEWMODEL] Logout error: $e');
      _currentUser = null;
      _accessToken = null;
      _userId = null;
      notifyListeners();
    }
  }

  // ==================== HELPERS ====================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _successMessage = null;
    notifyListeners();
  }

  void _setSuccess(String message) {
    _successMessage = message;
    _errorMessage = null;
    notifyListeners();
  }

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }

  String _formatErrorMessage(dynamic error) {
    String message = error.toString();
    message = message.replaceAll('Exception: ', '');

    if (message.contains('Email đã được đăng ký')) {
      return 'Email này đã được sử dụng';
    } else if (message.contains('Email hoặc mật khẩu không đúng')) {
      return 'Email hoặc mật khẩu không chính xác';
    } else if (message.contains('Email chưa được xác nhận')) {
      return 'Vui lòng xác nhận email trước khi đăng nhập';
    } else if (message.contains('timeout')) {
      return 'Không thể kết nối server';
    } else if (message.contains('SocketException')) {
      return 'Không có kết nối internet';
    }

    return message;
  }
}