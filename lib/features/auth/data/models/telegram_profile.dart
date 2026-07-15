class TelegramProfile {
  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String photoUrl;

  const TelegramProfile({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.photoUrl,
  });

  factory TelegramProfile.fromJson(Map<String, dynamic> json) {
    return TelegramProfile(
      id: json['id'] as int,
      username: (json['username'] as String?) ?? '',
      firstName: (json['first_name'] as String?) ?? '',
      lastName: (json['last_name'] as String?) ?? '',
      photoUrl: (json['photo_url'] as String?) ?? '',
    );
  }

  String get fullName {
    final name = [firstName, lastName].where((s) => s.isNotEmpty).join(' ');
    return name;
  }

  String get displayName {
    if (fullName.isNotEmpty) return fullName;
    if (username.isNotEmpty) return '@$username';
    return 'Telegram';
  }
}
