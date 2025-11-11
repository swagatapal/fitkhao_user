import 'package:flutter/material.dart';
import '../../../core/services/local_storage_service.dart';
import '../models/otp_request_model.dart';
import '../models/verify_otp_model.dart';

/// Repository for authentication related operations
/// Uses local storage and simulated data - no network calls required
class AuthRepository {
  final LocalStorageService _localStorage;

  AuthRepository({
    required LocalStorageService localStorage,
  }) : _localStorage = localStorage;

  /// Send OTP to phone number
  Future<OtpResponseModel> sendOTP({
    required String phoneNumber,
    required String countryCode,
  }) async {
    debugPrint('[AuthRepository] Sending OTP...');
    debugPrint('[AuthRepository] Phone: $countryCode $phoneNumber');

    // Simulate processing delay
    await Future.delayed(const Duration(seconds: 2));

    // Return success response
    return const OtpResponseModel(
      success: true,
      message: 'OTP sent successfully',
      otpId: 'otp_id_12345',
      expiresIn: 300, // 5 minutes
    );
  }

  /// Verify OTP
  /// Accepts "1234" as valid OTP
  Future<VerifyOtpResponseModel> verifyOTP({
    required String phoneNumber,
    required String countryCode,
    required String otp,
    String? otpId,
  }) async {
    debugPrint('[AuthRepository] Verifying OTP...');
    debugPrint('[AuthRepository] OTP: $otp');

    // Simulate processing delay
    await Future.delayed(const Duration(seconds: 1));

    // Accept "1234" as valid OTP
    if (otp == '1234') {
      // Success response
      final user = UserData(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        phoneNumber: phoneNumber,
        name: 'Test User',
        email: null,
        isNewUser: true,
      );

      const authToken = 'auth_token_xyz123';
      const refreshToken = 'refresh_token_abc456';

      // Save to local storage
      await _localStorage.saveAuthToken(authToken);
      await _localStorage.saveRefreshToken(refreshToken);
      await _localStorage.saveUserId(user.id);
      await _localStorage.saveUserPhone(user.phoneNumber);
      if (user.name != null) {
        await _localStorage.saveUserName(user.name!);
      }
      await _localStorage.setLoggedIn(true);

      debugPrint('[AuthRepository] OTP verified successfully');

      return VerifyOtpResponseModel(
        success: true,
        message: 'OTP verified successfully',
        authToken: authToken,
        refreshToken: refreshToken,
        user: user,
      );
    } else {
      // Invalid OTP response
      debugPrint('[AuthRepository] Invalid OTP');
      return const VerifyOtpResponseModel(
        success: false,
        message: 'Invalid OTP. Please try again.',
        authToken: null,
        refreshToken: null,
        user: null,
      );
    }
  }

  /// Resend OTP
  Future<OtpResponseModel> resendOTP({
    required String phoneNumber,
    required String countryCode,
  }) async {
    debugPrint('[AuthRepository] Resending OTP...');

    // Simulate processing delay
    await Future.delayed(const Duration(seconds: 1));

    return const OtpResponseModel(
      success: true,
      message: 'OTP resent successfully',
      otpId: 'otp_id_67890',
      expiresIn: 300,
    );
  }

  /// Logout user
  Future<void> logout() async {
    debugPrint('[AuthRepository] Logging out...');
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
