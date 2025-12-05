import 'user_model.dart';

class LoginResponse {
  final String message;
  final UserModel user;
  final String accessToken;
  final String refreshToken;

  LoginResponse({
    required this.message,
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      message: json['message'] ?? 'Login successful',
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      user: UserModel.fromJson(json['user']),
    );
  }
}