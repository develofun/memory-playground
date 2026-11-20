/// 아이 프로필. 개인정보 최소화를 위해 이름(별명)과 이모지 아바타만 저장한다.
class Profile {
  const Profile({
    required this.id,
    required this.name,
    required this.avatar,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String avatar;
  final DateTime createdAt;

  static const avatars = [
    '🐶', '🐱', '🐰', '🦊', '🐻', '🐼',
    '🐯', '🦁', '🐸', '🐵', '🦄', '🐧',
  ];

  Profile copyWith({String? name, String? avatar}) => Profile(
        id: id,
        name: name ?? this.name,
        avatar: avatar ?? this.avatar,
        createdAt: createdAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'avatar': avatar,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Profile.fromMap(Map<String, dynamic> map) => Profile(
        id: map['id'] as String,
        name: map['name'] as String,
        avatar: map['avatar'] as String,
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
}
