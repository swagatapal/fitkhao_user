/// Application configuration
/// Control app behavior with feature flags
class AppConfig {
  AppConfig._();

  /// Set to true to use mock data (no real API calls)
  /// Set to false when you have real API endpoints
  ///
  /// IMPORTANT: Change this to false when API is ready!
  static const bool useMockData = true;

  /// Show debug information in UI (for development)
  static const bool showDebugInfo = true;

  /// API Configuration (used when useMockData = false)
  static const String apiBaseUrl = 'https://fitkhao-user-registration-backend.onrender.com';
  static const int apiTimeout = 30; // seconds

  /// OTP Configuration
  static const int otpLength = 4;
  static const int otpResendTimerSeconds = 60;

  /// Mock OTP for testing (only used when useMockData = true)
  /// Use "1234" to successfully verify OTP in mock mode
  static const String mockValidOtp = '1234';
}
