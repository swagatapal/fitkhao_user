/// Application configuration
/// Control app behavior with feature flags
class AppConfig {
  AppConfig._();

  /// Show debug information in UI (for development)
  static const bool showDebugInfo = true;

  /// OTP Configuration
  static const int otpLength = 4;
  static const int otpResendTimerSeconds = 60;

  /// Valid OTP for verification
  /// Use "1234" to successfully verify OTP
  static const String mockValidOtp = '1234';

  /// App Version
  static const String appVersion = '1.0.0';

  /// App Name
  static const String appName = 'FitKhao';
}
