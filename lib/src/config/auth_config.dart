class AuthConfig {
  const AuthConfig({
    this.enableEmail = true,
    this.enableGoogle = true,
    this.enableApple = false,
  });

  final bool enableEmail;
  final bool enableGoogle;
  final bool enableApple;

  static const AuthConfig defaultConfig = AuthConfig();

  static const AuthConfig emailOnly = AuthConfig(
    enableEmail: true,
    enableGoogle: false,
    enableApple: false,
  );

  static const AuthConfig socialOnly = AuthConfig(
    enableEmail: false,
    enableGoogle: true,
    enableApple: true,
  );
}
