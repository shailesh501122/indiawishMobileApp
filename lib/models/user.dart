class UserBasic {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phoneNumber;
  final String? profilePicUrl;
  final DateTime? createdAt;
  final DateTime? lastSeen;
  final int followerCount;
  final int followingCount;
  final bool isElite;
  final String verificationLevel; // 'unverified', 'phone', 'id', 'top_seller'
  final String? referralCode;
  final double referralRewardBalance;

  UserBasic({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phoneNumber,
    this.profilePicUrl,
    this.createdAt,
    this.lastSeen,
    this.followerCount = 0,
    this.followingCount = 0,
    this.isElite = false,
    this.verificationLevel = 'unverified',
    this.referralCode,
    this.referralRewardBalance = 0.0,
  });

  /// The backend returns snake_case from /users/me but camelCase from /auth/login user field.
  /// This handles both gracefully.
  factory UserBasic.fromJson(Map<String, dynamic> json) {
    return UserBasic(
      id: (json['id'] ?? '').toString(),
      firstName: json['firstName'] ?? json['first_name'] ?? '',
      lastName: json['lastName'] ?? json['last_name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? json['phone_number'],
      profilePicUrl: json['profilePicUrl'] ?? json['profile_pic_url'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : (json['createdAt'] != null
                ? DateTime.tryParse(json['createdAt'].toString())
                : null),
      lastSeen: (json['lastSeen'] ?? json['last_seen']) != null
          ? DateTime.tryParse(
              (json['lastSeen'] ?? json['last_seen']).toString(),
            )
          : null,
      followerCount: json['follower_count'] ?? json['followerCount'] ?? 0,
      followingCount: json['following_count'] ?? json['followingCount'] ?? 0,
      isElite: json['is_elite'] ?? json['isElite'] ?? false,
      verificationLevel:
          json['verification_level'] ??
          json['verificationLevel'] ??
          'unverified',
      referralCode: json['referral_code'] ?? json['referralCode'],
      referralRewardBalance:
          (json['referral_reward_balance'] ??
                  json['referralRewardBalance'] ??
                  0.0)
              .toDouble(),
    );
  }

  String get fullName => '$firstName $lastName'.trim();
}
