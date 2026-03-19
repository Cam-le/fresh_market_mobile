class UserModel {
  String name;
  String email;
  String phone;
  String city;
  String? avatarUrl;
  final DateTime joinedAt;

  UserModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.city,
    this.avatarUrl,
    DateTime? joinedAt,
  }) : joinedAt = joinedAt ?? DateTime(2026, 2, 1);

  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? city,
    String? avatarUrl,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      joinedAt: joinedAt,
    );
  }
}
