import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/services/local_storage_service.dart';
import '../models/otp_request_model.dart';
import '../models/verify_otp_model.dart';

/// Repository for authentication related operations
class AuthRepository {
  final ApiClient _apiClient;
  final LocalStorageService _localStorage;

  AuthRepository({
    required ApiClient apiClient,
    required LocalStorageService localStorage,
  })  : _apiClient = apiClient,
        _localStorage = localStorage;

  /// Send OTP to phone number
  Future<OtpResponseModel> sendOTP({
    required String phoneNumber,
    required String countryCode,
  }) async {
    final request = OtpRequestModel(
      phoneNumber: phoneNumber,
      countryCode: countryCode,
    );

    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.sendOTP,
      data: request.toJson(),
    );

    return OtpResponseModel.fromJson(response);
  }

  /// Verify OTP
  Future<VerifyOtpResponseModel> verifyOTP({
    required String phoneNumber,
    required String countryCode,
    required String otp,
    String? otpId,
  }) async {
    final request = VerifyOtpRequestModel(
      phoneNumber: phoneNumber,
      countryCode: countryCode,
      otp: otp,
      otpId: otpId,
    );

    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.verifyOTP,
      data: request.toJson(),
    );

    final otpResponse = VerifyOtpResponseModel.fromJson(response);

    // Save tokens and user data to local storage
    if (otpResponse.success && otpResponse.authToken != null) {
      await _localStorage.saveAuthToken(otpResponse.authToken!);
      if (otpResponse.refreshToken != null) {
        await _localStorage.saveRefreshToken(otpResponse.refreshToken!);
      }
      if (otpResponse.user != null) {
        await _localStorage.saveUserId(otpResponse.user!.id);
        await _localStorage.saveUserPhone(otpResponse.user!.phoneNumber);
        if (otpResponse.user!.name != null) {
          await _localStorage.saveUserName(otpResponse.user!.name!);
        }
        if (otpResponse.user!.email != null) {
          await _localStorage.saveUserEmail(otpResponse.user!.email!);
        }
      }
      await _localStorage.setLoggedIn(true);

      // Set auth token in API client
      _apiClient.setAuthToken(otpResponse.authToken!);
    }

    return otpResponse;
  }

  /// Resend OTP
  Future<OtpResponseModel> resendOTP({
    required String phoneNumber,
    required String countryCode,
  }) async {
    final request = OtpRequestModel(
      phoneNumber: phoneNumber,
      countryCode: countryCode,
    );

    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.resendOTP,
      data: request.toJson(),
    );

    return OtpResponseModel.fromJson(response);
  }

  /// Logout user
  Future<void> logout() async {
    try {
      // Call logout API
      await _apiClient.post(ApiEndpoints.logout);
    } catch (e) {
      // Continue with local logout even if API fails
    } finally {
      // Clear local storage
      await _localStorage.clearUserData();

      // Remove auth token from API client
      _apiClient.removeAuthToken();
    }
  }

  /// Check if user is logged in
  bool isLoggedIn() {
    return _localStorage.isLoggedIn();
  }

  /// Get stored auth token
  String? getAuthToken() {
    return _localStorage.getAuthToken();
  }

  /// Get stored user phone
  String? getUserPhone() {
    return _localStorage.getUserPhone();
  }
}
