import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/providers.dart';
import '../models/auth_state.dart';
import '../repository/auth_repository.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  Timer? _resendTimer;
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(const AuthState());

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }

  void updatePhoneNumber(String phoneNumber) {
    state = state.copyWith(phoneNumber: phoneNumber, errorMessage: null);
  }

  void updateCountryCode(String countryCode) {
    state = state.copyWith(countryCode: countryCode);
  }

  void updateOtp(String otp) {
    state = state.copyWith(otp: otp, errorMessage: null);
  }

  void toggleTermsAccepted() {
    state = state.copyWith(isTermsAccepted: !state.isTermsAccepted);
  }

  void setTermsAccepted(bool value) {
    state = state.copyWith(isTermsAccepted: value);
  }

  String? validatePhoneNumber() {
    // No need to check for empty since button is disabled until 10 digits entered
    if (state.phoneNumber.length != 10) {
      return 'Please enter a valid 10-digit phone number';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(state.phoneNumber)) {
      return 'Phone number should contain only digits';
    }
    return null;
  }

  String? validateOtp() {
    if (state.otp.isEmpty) {
      return 'Please enter OTP';
    }
    if (state.otp.length != 6) {
      return 'Please enter complete 6-digit OTP';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(state.otp)) {
      return 'OTP should contain only digits';
    }
    return null;
  }

  bool validateForm() {
    final phoneError = validatePhoneNumber();
    if (phoneError != null) {
      state = state.copyWith(errorMessage: phoneError);
      return false;
    }

    if (!state.isTermsAccepted) {
      state = state.copyWith(
        errorMessage: 'Please accept the terms and conditions',
      );
      return false;
    }

    state = state.copyWith(errorMessage: null);
    return true;
  }

  bool validateOtpForm() {
    final otpError = validateOtp();
    if (otpError != null) {
      state = state.copyWith(errorMessage: otpError);
      return false;
    }

    state = state.copyWith(errorMessage: null);
    return true;
  }

  /// Send OTP to the provided phone number
  Future<bool> sendOtp() async {
    if (!validateForm()) {
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _authRepository.sendOTP(
        phoneNumber: state.phoneNumber,
      );

      if (response.success) {
        // Start resend timer
        state = state.copyWith(
          isLoading: false,
          errorMessage: null,
          receivedOtpMessage: response.message,
        );
        _startResendTimer();
        return true;
      } else {
        debugPrint('[AuthNotifier] Send OTP failed: '
            '${response.error?.details ?? response.message}');
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.message,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  /// Verify OTP
  Future<bool> verifyOtp() async {
    if (!validateOtpForm()) {
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _authRepository.verifyOTP(
        phoneNumber: state.phoneNumber,
        countryCode: state.countryCode,
        otp: state.otp,
      );

      if (response.success) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: null,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.message,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  /// Resend OTP
  Future<bool> resendOtp() async {
    state = state.copyWith(isResendingOtp: true, errorMessage: null);

    try {
      final response = await _authRepository.resendOTP(
        phoneNumber: state.phoneNumber,
        countryCode: state.countryCode,
      );

      if (response.success) {
        state = state.copyWith(
          isResendingOtp: false,
          errorMessage: null,
          receivedOtpMessage: response.message,
        );
        _startResendTimer();
        return true;
      } else {
        state = state.copyWith(
          isResendingOtp: false,
          errorMessage: response.message,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isResendingOtp: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  /// Start resend timer
  void _startResendTimer() {
    _resendTimer?.cancel();
    state = state.copyWith(
      resendTimer: 60,
      canResend: false,
    );

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.resendTimer > 0) {
        state = state.copyWith(resendTimer: state.resendTimer - 1);
      } else {
        state = state.copyWith(canResend: true);
        timer.cancel();
      }
    });
  }

  /// Save user name
  void saveName(String name) {
    state = state.copyWith(name: name);
  }

  /// Save user gender and date of birth
  void savePersonalInfo({
    required String gender,
    required DateTime dateOfBirth,
    required double height,
    required double weight,
    required bool doesExercise,
  }) {
    state = state.copyWith(
      gender: gender,
      dateOfBirth: dateOfBirth,
      height: height,
      weight: weight,
      doesExercise: doesExercise,
    );
  }

  /// Save address information
  void saveAddress({
    required String buildingNameNumber,
    required String street,
    required String pincode,
    double? latitude,
    double? longitude,
  }) {
    state = state.copyWith(
      buildingNameNumber: buildingNameNumber,
      street: street,
      pincode: pincode,
      latitude: latitude,
      longitude: longitude,
    );
  }

  /// Save BMI and health score
  void saveHealthData({
    required double bmi,
    required int healthScore,
  }) {
    state = state.copyWith(
      bmi: bmi,
      healthScore: healthScore,
    );
  }

  /// Save detailed health information
  void saveDetailedHealthInfo({
    required double height,
    required double weight,
    required String physicalActivityLevel,
    required bool doesExercise,
    int? exerciseDaysPerWeek,
    double? exerciseDurationHours,
    required String exerciseType,
    required bool pregnancy,
    required bool lactation,
    required bool diabetes,
    required bool hypertension,
    required bool cardiacProblem,
    required bool kidneyDisease,
    required bool liverRelatedProblem,
    required String otherConditions,
    required String regularityStatus,
  }) {
    state = state.copyWith(
      height: height,
      weight: weight,
      physicalActivityLevel: physicalActivityLevel,
      doesExercise: doesExercise,
      exerciseDaysPerWeek: exerciseDaysPerWeek,
      exerciseDurationHours: exerciseDurationHours,
      exerciseType: exerciseType,
      pregnancy: pregnancy,
      lactation: lactation,
      diabetes: diabetes,
      hypertension: hypertension,
      cardiacProblem: cardiacProblem,
      kidneyDisease: kidneyDisease,
      liverRelatedProblem: liverRelatedProblem,
      otherConditions: otherConditions,
      regularityStatus: regularityStatus,
    );
  }

  /// Complete registration with all collected data
  /// Stores data locally - no API calls
  Future<bool> completeRegistration() async {
    // Validate all required data is present
    if (state.phoneNumber.isEmpty ||
        state.name.isEmpty ||
        state.dateOfBirth == null ||
        state.height == null ||
        state.weight == null ||
        state.buildingNameNumber.isEmpty ||
        state.street.isEmpty ||
        state.pincode.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Missing required information. Please complete all steps.',
      );
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Simulate processing delay
      await Future.delayed(const Duration(seconds: 1));

      // All data is already stored in the state
      // Mark registration as complete
      state = state.copyWith(
        isLoading: false,
        errorMessage: null,
      );

      debugPrint('[AuthNotifier] Registration completed successfully');
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  /// Check if user exists by phone number
  /// Returns true if user is already logged in
  Future<bool> getUserByPhone(String phoneNumber) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Simulate processing delay
      await Future.delayed(const Duration(seconds: 1));

      // Check if user is logged in via repository
      final isLoggedIn = _authRepository.isLoggedIn();
      final storedPhone = _authRepository.getUserPhone();

      if (isLoggedIn && storedPhone == phoneNumber) {
        // User exists and is logged in
        state = state.copyWith(
          isLoading: false,
          phoneNumber: phoneNumber,
          errorMessage: null,
        );
        return true;
      } else {
        // User doesn't exist or not logged in
        state = state.copyWith(
          isLoading: false,
          errorMessage: null,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void reset() {
    _resendTimer?.cancel();
    state = const AuthState();
  }
}

// Extension to capitalize first letter
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

// Provider for AuthNotifier
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository);
});
