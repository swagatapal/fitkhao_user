import 'package:flutter/material.dart';
import '../../../core/services/local_storage_service.dart';
import '../models/otp_request_model.dart';
import '../models/verify_otp_model.dart';

/// Mock implementation of AuthRepository for testing without real API
/// This allows frontend development without backend dependency
class MockAuthRepository {
  final LocalStorageService _localStorage;

  MockAuthRepository({
    required LocalStorageService localStorage,
  }) : _localStorage = localStorage;

  /// Mock Send OTP - Always returns success
  Future<OtpResponseModel> sendOTP({
    required String phoneNumber,
    required String countryCode,
  }) async {
    debugPrint('[MockAuthRepository] Simulating sendOTP API call...');
    debugPrint('[MockAuthRepository] Phone: $countryCode $phoneNumber');

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Return mock success response
    return const OtpResponseModel(
      success: true,
      message: 'OTP sent successfully',
      otpId: 'mock_otp_id_12345',
      expiresIn: 300, // 5 minutes
    );
  }

  /// Mock Verify OTP
  /// Accepts any 4-digit OTP for testing
  /// Use "1234" for success, any other for failure demo
  Future<VerifyOtpResponseModel> verifyOTP({
    required String phoneNumber,
    required String countryCode,
    required String otp,
    String? otpId,
  }) async {
    debugPrint('[MockAuthRepository] Simulating verifyOTP API call...');
    debugPrint('[MockAuthRepository] OTP: $otp');

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // For demo: Accept "1234" as valid OTP, reject others
    if (otp == '1234') {
      // Mock success response
      final mockUser = UserData(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        phoneNumber: phoneNumber,
        name: 'Test User',
        email: null,
        isNewUser: true,
      );

      const mockAuthToken = 'mock_auth_token_xyz123';
      const mockRefreshToken = 'mock_refresh_token_abc456';

      // Save to local storage
      await _localStorage.saveAuthToken(mockAuthToken);
      await _localStorage.saveRefreshToken(mockRefreshToken);
      await _localStorage.saveUserId(mockUser.id);
      await _localStorage.saveUserPhone(mockUser.phoneNumber);
      if (mockUser.name != null) {
        await _localStorage.saveUserName(mockUser.name!);
      }
      await _localStorage.setLoggedIn(true);

      debugPrint('[MockAuthRepository] OTP verified successfully');

      return VerifyOtpResponseModel(
        success: true,
        message: 'OTP verified successfully',
        authToken: mockAuthToken,
        refreshToken: mockRefreshToken,
        user: mockUser,
      );
    } else {
      // Mock failure response for wrong OTP
      debugPrint('[MockAuthRepository] Invalid OTP');
      return const VerifyOtpResponseModel(
        success: false,
        message: 'Invalid OTP. Please try again.',
        authToken: null,
        refreshToken: null,
        user: null,
      );
    }
  }

  /// Mock Resend OTP - Always returns success
  Future<OtpResponseModel> resendOTP({
    required String phoneNumber,
    required String countryCode,
  }) async {
    debugPrint('[MockAuthRepository] Simulating resendOTP API call...');

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    return const OtpResponseModel(
      success: true,
      message: 'OTP resent successfully',
      otpId: 'mock_otp_id_67890',
      expiresIn: 300,
    );
  }

  /// Mock Logout
  Future<void> logout() async {
    debugPrint('[MockAuthRepository] Simulating logout...');
    await _localStorage.clearUserData();
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
