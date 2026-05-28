class User {
  final String id;
  final String nickname;
  final String? profileImageUrl;

  const User({
    required this.id,
    required this.nickname,
    this.profileImageUrl,
  });

  User copyWith({String? nickname, String? profileImageUrl}) {
    return User(
      id: id,
      nickname: nickname ?? this.nickname,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        nickname: json['nickname'] as String,
        profileImageUrl: json['profileImageUrl'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nickname': nickname,
        'profileImageUrl': profileImageUrl,
      };
}
