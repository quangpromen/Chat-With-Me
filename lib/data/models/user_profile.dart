class UserProfile {
  const UserProfile({
    required this.id,
    required this.displayName,
    this.avatarPath,
    required this.deviceId,
    this.pubKey,
    this.privKey,
  });

  final String id;
  final String displayName;
  final String? avatarPath;
  final String deviceId;
  final String? pubKey;
  final String? privKey;
}
