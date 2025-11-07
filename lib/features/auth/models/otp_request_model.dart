/// Request model for sending OTP
class OtpRequestModel {
  final String phoneNumber;
  final String countryCode;

  const OtpRequestModel({
    required this.phoneNumber,
    required this.countryCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone_number': phoneNumber,
      'country_code': countryCode,
    };
  }
}

/// Response model for OTP sent
class OtpResponseModel {
  final bool success;
  final String message;
  final String? otpId;
  final int? expiresIn;

  const OtpResponseModel({
    required this.success,
    required this.message,
    this.otpId,
    this.expiresIn,
  });

  factory OtpResponseModel.fromJson(Map<String, dynamic> json) {
    return OtpResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      otpId: json['otp_id'] as String?,
      expiresIn: json['expires_in'] as int?,
    );
  }
}
