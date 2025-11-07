import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_state.dart';
import '../services/auth_service.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  Timer? _resendTimer;
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState());

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
    if (state.otp.length != 4) {
      return 'Please enter complete 4-digit OTP';
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
      final response = await _authService.sendOtp(
        phoneNumber: state.phoneNumber,
        termsAccepted: state.isTermsAccepted,
      );

      if (response.success) {
        // Store OTP message and start resend timer
        state = state.copyWith(
          isLoading: false,
          errorMessage: null,
          receivedOtpMessage: response.data?.message,
        );
        _startResendTimer();
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

  /// Register/Verify OTP
  Future<RegisterResponse?> verifyOtp() async {
    if (!validateOtpForm()) {
      return null;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _authService.register(
        phoneNumber: state.phoneNumber,
        otp: state.otp,
      );

      if (response.success) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: null,
        );
        return response;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.message,
        );
        return null;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return null;
    }
  }

  /// Resend OTP
  Future<bool> resendOtp() async {
    state = state.copyWith(isResendingOtp: true, errorMessage: null);

    try {
      final response = await _authService.sendOtp(
        phoneNumber: state.phoneNumber,
        termsAccepted: true,
      );

      if (response.success) {
        state = state.copyWith(
          isResendingOtp: false,
          errorMessage: null,
          receivedOtpMessage: response.data?.message,
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
  Future<RegisterResponse?> completeRegistration() async {
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
      return null;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _authService.completeRegistration(
        phoneNumber: state.phoneNumber,
        name: state.name,
        gender: state.gender.capitalize(),
        dateOfBirth: state.dateOfBirth!,
        height: state.height!,
        weight: state.weight!,
        buildingNameNumber: state.buildingNameNumber,
        street: state.street,
        pincode: state.pincode,
        latitude: state.latitude,
        longitude: state.longitude,
        doesExercise: state.doesExercise,
        termsAccepted: state.isTermsAccepted,
        physicalActivityLevel: state.physicalActivityLevel,
        exerciseDaysPerWeek: state.exerciseDaysPerWeek,
        exerciseDurationHours: state.exerciseDurationHours,
        exerciseType: state.exerciseType,
        pregnancy: state.pregnancy,
        lactation: state.lactation,
        diabetes: state.diabetes,
        hypertension: state.hypertension,
        cardiacProblem: state.cardiacProblem,
        kidneyDisease: state.kidneyDisease,
        liverRelatedProblem: state.liverRelatedProblem,
        otherConditions: state.otherConditions,
        regularityStatus: state.regularityStatus,
      );

      if (response.success) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: null,
        );
        return response;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.message,
        );
        return null;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return null;
    }
  }

  /// Fetch user data by phone number
  Future<RegisterResponse?> getUserByPhone(String phoneNumber) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _authService.getUserByPhone(
        phoneNumber: phoneNumber,
      );

      if (response.success && response.data != null) {
        // Update state with fetched user data
        final user = response.data!.user;
        state = state.copyWith(
          isLoading: false,
          phoneNumber: user.phoneNumber,
          name: user.name ?? '',
          gender: user.gender?.toLowerCase() ?? 'female',
          dateOfBirth: user.dateOfBirth,
          height: user.height,
          weight: user.weight,
          bmi: user.bmi,
          healthScore: user.healthScore,
          buildingNameNumber: user.buildingNameNumber ?? '',
          street: user.street ?? '',
          pincode: user.pincode ?? '',
          errorMessage: null,
        );
        return response;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.message,
        );
        return null;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return null;
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

// Provider for AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Provider for AuthNotifier
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});
