class UserModel {
  final int accountId;
  final String username;
  String name;
  String email;
  String phone;
  String city;
  String? avatarUrl;
  final int role; // 2 = CUSTOMER, from API
  final DateTime joinedAt;

  UserModel({
    this.accountId = 0,
    this.username = '',
    required this.name,
    required this.email,
    required this.phone,
    required this.city,
    this.avatarUrl,
    this.role = 2,
    DateTime? joinedAt,
  }) : joinedAt = joinedAt ?? DateTime(2026, 2, 1);

  UserModel copyWith({
    int? accountId,
    String? username,
    String? name,
    String? email,
    String? phone,
    String? city,
    String? avatarUrl,
    int? role,
  }) {
    return UserModel(
      accountId: accountId ?? this.accountId,
      username: username ?? this.username,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      joinedAt: joinedAt,
    );
  }

  /// Safe fromJson — every field has a fallback so a partial/unexpected API
  /// response never throws.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      accountId: _parseInt(json['accountId']),
      username: _parseStr(json['username']),
      name: _parseStr(json['name'], fallback: _parseStr(json['username'])),
      email: _parseStr(json['email']),
      phone: _parseStr(json['phone']),
      city: _parseStr(json['city']),
      avatarUrl: json['avatarUrl'] as String?,
      role: _parseInt(json['role'], fallback: 2),
      joinedAt: _parseDate(json['joinedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'accountId': accountId,
        'username': username,
        'name': name,
        'email': email,
        'phone': phone,
        'city': city,
        'avatarUrl': avatarUrl,
        'role': role,
        'joinedAt': joinedAt.toIso8601String(),
      };

  // ── Mock default user (used when no session exists) ──────────────────────
  static UserModel get mock => UserModel(
        accountId: 0,
        username: 'guest',
        name: 'Nguyễn Văn A',
        email: 'user@example.com',
        phone: '0961231158',
        city: 'Hồ Chí Minh',
        role: 2,
        joinedAt: DateTime(2026, 2, 1),
      );

  // ── Safe parse helpers ────────────────────────────────────────────────────

  static int _parseInt(dynamic v, {int fallback = 0}) {
    if (v is int) return v;
    if (v is String) return int.tryParse(v) ?? fallback;
    return fallback;
  }

  static String _parseStr(dynamic v, {String fallback = ''}) {
    if (v is String) return v;
    return fallback;
  }

  static DateTime _parseDate(dynamic v) {
    if (v is String) return DateTime.tryParse(v) ?? DateTime(2026, 2, 1);
    return DateTime(2026, 2, 1);
  }
}
