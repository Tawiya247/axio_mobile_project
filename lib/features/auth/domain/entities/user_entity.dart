class UserEntity {
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;
  final String? token;

  const UserEntity({
    required this.id,
    required this.email,
    this.name,
    this.photoUrl,
    this.token,
  });

  // Pour la conversion depuis/sur JSON
  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      photoUrl: json['photoUrl'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    if (name != null) 'name': name,
    if (photoUrl != null) 'photoUrl': photoUrl,
    if (token != null) 'token': token,
  };

  // Pour la mise à jour des propriétés
  UserEntity copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    String? token,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      token: token ?? this.token,
    );
  }

  // Pour la comparaison d'objets
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserEntity &&
        other.id == id &&
        other.email == email &&
        other.name == name &&
        other.photoUrl == photoUrl &&
        other.token == token;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        (name?.hashCode ?? 0) ^
        (photoUrl?.hashCode ?? 0) ^
        (token?.hashCode ?? 0);
  }

  @override
  String toString() {
    return 'UserEntity(id: $id, email: $email, name: $name, photoUrl: $photoUrl)';
  }
}
