import 'package:equatable/equatable.dart';

import 'user_entity.dart';

// Modèle pour la demande de connexion
class LoginRequest extends Equatable {
  final String email;
  final String password;

  const LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};

  @override
  List<Object?> get props => [email, password];
}

// Modèle pour la réponse de connexion
class LoginResponse extends Equatable {
  final String accessToken;
  final String? refreshToken;
  final UserEntity user;

  const LoginResponse({
    required this.accessToken,
    this.refreshToken,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['accessToken'] ?? json['token'],
      refreshToken: json['refreshToken'],
      user: UserEntity.fromJson(
        json['user'] is Map<String, dynamic>
            ? json['user']
            : {'id': json['userId'] ?? ''},
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    if (refreshToken != null) 'refreshToken': refreshToken,
    'user': user.toJson(),
  };

  @override
  List<Object?> get props => [accessToken, refreshToken, user];
}

// Modèle pour la demande d'inscription
class RegisterRequest extends Equatable {
  final String name;
  final String email;
  final String password;
  final String confirmPassword;

  const RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'password': password,
  };

  @override
  List<Object?> get props => [name, email, password, confirmPassword];
}

// Modèle pour la réponse d'inscription
class RegisterResponse extends Equatable {
  final String accessToken;
  final String? refreshToken;
  final UserEntity user;

  const RegisterResponse({
    required this.accessToken,
    this.refreshToken,
    required this.user,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      accessToken: json['accessToken'] ?? json['token'],
      refreshToken: json['refreshToken'],
      user: UserEntity.fromJson(
        json['user'] is Map<String, dynamic>
            ? json['user']
            : {'id': json['userId'] ?? ''},
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    if (refreshToken != null) 'refreshToken': refreshToken,
    'user': user.toJson(),
  };

  @override
  List<Object?> get props => [accessToken, refreshToken, user];
}

// Modèle pour la réponse de l'utilisateur connecté
class MeResponse extends Equatable {
  final UserEntity user;

  const MeResponse({required this.user});

  factory MeResponse.fromJson(Map<String, dynamic> json) {
    return MeResponse(user: UserEntity.fromJson(json));
  }

  Map<String, dynamic> toJson() => user.toJson();

  @override
  List<Object?> get props => [user];
}
