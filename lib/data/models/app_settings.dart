class AppSettings {
  const AppSettings({
    required this.themeMode,
    required this.language,
    required this.networkPref,
    this.lastHostIp,
  });

  final String themeMode;
  final String language;
  final String networkPref;
  final String? lastHostIp;
}
