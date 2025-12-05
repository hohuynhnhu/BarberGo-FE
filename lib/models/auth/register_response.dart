import 'user_model.dart';

class RegisterResponse {
  final String message;
  final UserModel user;
  final String note;
  final bool emailConfirmed;

  RegisterResponse({
    required this.message,
    required this.user,
    required this.note,
    required this.emailConfirmed,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      message: json['message'] ?? '',
      note: json['note'] ?? '',
      emailConfirmed: json['user']['email_confirmed'] ?? false,
      user: UserModel.fromJson(json['user']),
    );
  }
}