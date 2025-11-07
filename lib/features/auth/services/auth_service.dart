import 'package:dio/dio.dart';
import '../../../core/config/app_config.dart';

/// Response data model for send OTP API
class SendOtpData {
  final String phoneNumber;
  final String expiresAt;
  final String expiresIn;
  final bool isExistingUser;
  final String message;

  SendOtpData({
    required this.phoneNumber,
    required this.expiresAt,
    required this.expiresIn,
    required this.isExistingUser,
    required this.message,
  });

  factory SendOtpData.fromJson(Map<String, dynamic> json) {
    return SendOtpData(
      phoneNumber: json['phoneNumber'] ?? '',
      expiresAt: json['expiresAt'] ?? '',
      expiresIn: json['expiresIn'] ?? '',
      isExistingUser: json['isExistingUser'] ?? false,
      message: json['message'] ?? '',
    );
  }
}

/// Response model for send OTP API
class SendOtpResponse {
  final bool success;
  final String message;
  final SendOtpData? data;

  SendOtpResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory SendOtpResponse.fromJson(Map<String, dynamic> json) {
    return SendOtpResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? SendOtpData.fromJson(json['data']) : null,
    );
  }
}

/// User model for register response
class User {
  final String id;
  final String phoneNumber;
  final String? name;
  final String? profilePicture;
  final bool isVerified;
  final int healthScore;
  final double? bmi;
  final int? age;
  final String? gender;
  final DateTime? dateOfBirth;
  final double? height;
  final double? weight;
  final String? buildingNameNumber;
  final String? street;
  final String? pincode;

  User({
    required this.id,
    required this.phoneNumber,
    this.name,
    this.profilePicture,
    required this.isVerified,
    required this.healthScore,
    this.bmi,
    this.age,
    this.gender,
    this.dateOfBirth,
    this.height,
    this.weight,
    this.buildingNameNumber,
    this.street,
    this.pincode,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final address = json['address'] as Map<String, dynamic>?;

    return User(
      id: json['id'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      name: json['name'],
      profilePicture: json['profilePicture'],
      isVerified: json['isVerified'] ?? false,
      healthScore: json['healthScore'] ?? 0,
      bmi: json['bmi']?.toDouble(),
      age: json['age'],
      gender: json['gender'],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : null,
      height: json['height']?.toDouble(),
      weight: json['weight']?.toDouble(),
      buildingNameNumber: address?['buildingNameNumber'],
      street: address?['street'],
      pincode: address?['pincode'],
    );
  }
}

/// Register response data model
class RegisterData {
  final User user;
  final bool isNewUser;

  RegisterData({
    required this.user,
    required this.isNewUser,
  });

  factory RegisterData.fromJson(Map<String, dynamic> json) {
    return RegisterData(
      user: User.fromJson(json['user']),
      isNewUser: json['isNewUser'] ?? false,
    );
  }
}

/// Response model for register API
class RegisterResponse {
  final bool success;
  final String message;
  final RegisterData? data;

  RegisterResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? RegisterData.fromJson(json['data']) : null,
    );
  }
}

/// Authentication service to handle API calls
class AuthService {
  late final Dio _dio;

  AuthService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: Duration(seconds: AppConfig.apiTimeout),
        receiveTimeout: Duration(seconds: AppConfig.apiTimeout),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    // Add interceptors for logging (optional, can be removed in production)
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        requestHeader: true,
        responseHeader: false,
      ),
    );
  }

  /// Send OTP to the provided phone number
  ///
  /// Parameters:
  /// - [phoneNumber]: The phone number to send OTP to (10 digits)
  /// - [termsAccepted]: Whether the user has accepted terms and conditions
  ///
  /// Returns:
  /// - [SendOtpResponse] with success status and message
  ///
  /// Throws:
  /// - [DioException] if the request fails
  Future<SendOtpResponse> sendOtp({
    required String phoneNumber,
    required bool termsAccepted,
  }) async {
    try {
      final response = await _dio.post(
        '/api/auth/send-otp',
        data: {
          'phoneNumber': phoneNumber,
          'termsAccepted': termsAccepted,
        },
      );

      return SendOtpResponse.fromJson(response.data);
    } on DioException catch (e) {
      // Handle different types of errors
      if (e.response != null) {
        // Server responded with an error
        final data = e.response!.data;
        if (data is Map<String, dynamic>) {
          throw Exception(data['message'] ?? 'Failed to send OTP');
        }
        throw Exception('Failed to send OTP: ${e.response!.statusCode}');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Request timeout. Please check your internet connection');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Connection failed. Please check your internet connection');
      } else {
        throw Exception('Failed to send OTP: ${e.message}');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Register/Verify OTP (Quick verification)
  Future<RegisterResponse> register({
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      final response = await _dio.post(
        '/api/auth/register',
        data: {
          'phoneNumber': phoneNumber,
          'otp': otp,
        },
      );

      return RegisterResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        final data = e.response!.data;
        if (data is Map<String, dynamic>) {
          throw Exception(data['message'] ?? 'Failed to verify OTP');
        }
        throw Exception('Failed to verify OTP: ${e.response!.statusCode}');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Request timeout. Please check your internet connection');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Connection failed. Please check your internet connection');
      } else {
        throw Exception('Failed to verify OTP: ${e.message}');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Complete Registration with full user details
  Future<RegisterResponse> completeRegistration({
    required String phoneNumber,
    required String name,
    required String gender,
    required DateTime dateOfBirth,
    required double height,
    required double weight,
    required String buildingNameNumber,
    required String street,
    required String pincode,
    double? latitude,
    double? longitude,
    required bool doesExercise,
    required bool termsAccepted,
    String? physicalActivityLevel,
    int? exerciseDaysPerWeek,
    double? exerciseDurationHours,
    String? exerciseType,
    bool? pregnancy,
    bool? lactation,
    bool? diabetes,
    bool? hypertension,
    bool? cardiacProblem,
    bool? kidneyDisease,
    bool? liverRelatedProblem,
    String? otherConditions,
    String? regularityStatus,
  }) async {
    try {
      // Format date to ISO 8601 string
      final formattedDate = dateOfBirth.toIso8601String().split('T')[0];

      // Prepare request body (no OTP needed as user is already verified)
      final Map<String, dynamic> requestBody = {
        'phoneNumber': phoneNumber,
        'name': name,
        'gender': gender,
        'dateOfBirth': formattedDate,
        'height': height,
        'weight': weight,
        'address': {
          'buildingNameNumber': buildingNameNumber,
          'street': street,
          'pincode': pincode,
        },
        'workoutInformation': {
          'doesExercise': doesExercise,
          if (exerciseDaysPerWeek != null) 'daysPerWeek': exerciseDaysPerWeek,
          if (exerciseDurationHours != null) 'durationInHours': exerciseDurationHours,
          if (exerciseType != null) 'exerciseType': exerciseType,
        },
        'termsAccepted': termsAccepted,
      };

      // Add physical activity level if provided
      if (physicalActivityLevel != null) {
        requestBody['physicalActivityLevel'] = physicalActivityLevel;
      }

      // Add physiological status if provided
      if (pregnancy != null || lactation != null || diabetes != null ||
          hypertension != null || cardiacProblem != null || kidneyDisease != null ||
          liverRelatedProblem != null) {
        requestBody['physiologicalStatus'] = {
          'pregnancy': pregnancy ?? false,
          'lactation': lactation ?? false,
          'diabetes': diabetes ?? false,
          'hypertension': hypertension ?? false,
          'cardiacProblem': cardiacProblem ?? false,
          'kidneyDisease': kidneyDisease ?? false,
          'liverRelatedProblem': liverRelatedProblem ?? false,
          'others': otherConditions ?? '',
        };
      }

      // Add regularity status if provided
      if (regularityStatus != null) {
        requestBody['regularity'] = regularityStatus;
      }

      // Add location if available
      if (latitude != null && longitude != null) {
        requestBody['address']['location'] = {
          'type': 'Point',
          'coordinates': [longitude, latitude],
        };
      }

      final response = await _dio.post(
        '/api/auth/register',
        data: requestBody,
      );

      return RegisterResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        final data = e.response!.data;
        if (data is Map<String, dynamic>) {
          throw Exception(data['message'] ?? 'Failed to complete registration');
        }
        throw Exception('Failed to complete registration: ${e.response!.statusCode}');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Request timeout. Please check your internet connection');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Connection failed. Please check your internet connection');
      } else {
        throw Exception('Failed to complete registration: ${e.message}');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Get user by phone number
  Future<RegisterResponse> getUserByPhone({
    required String phoneNumber,
  }) async {
    try {
      final response = await _dio.get(
        '/api/auth/user/$phoneNumber',
      );

      return RegisterResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        final data = e.response!.data;
        if (data is Map<String, dynamic>) {
          throw Exception(data['message'] ?? 'Failed to fetch user data');
        }
        throw Exception('Failed to fetch user data: ${e.response!.statusCode}');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Request timeout. Please check your internet connection');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Connection failed. Please check your internet connection');
      } else {
        throw Exception('Failed to fetch user data: ${e.message}');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Resend OTP
  Future<SendOtpResponse> resendOtp({
    required String phoneNumber,
  }) async {
    try {
      final response = await _dio.post(
        '/api/auth/resend-otp',
        data: {
          'phoneNumber': phoneNumber,
        },
      );

      return SendOtpResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        final data = e.response!.data;
        if (data is Map<String, dynamic>) {
          throw Exception(data['message'] ?? 'Failed to resend OTP');
        }
        throw Exception('Failed to resend OTP: ${e.response!.statusCode}');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Request timeout. Please check your internet connection');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Connection failed. Please check your internet connection');
      } else {
        throw Exception('Failed to resend OTP: ${e.message}');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
