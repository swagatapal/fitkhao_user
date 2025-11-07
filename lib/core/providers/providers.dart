import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../services/local_storage_service.dart';
import '../services/phone_number_service.dart';
import '../../features/auth/repository/auth_repository.dart';
import '../../features/auth/repository/mock_auth_repository.dart';

/// Provider for LocalStorageService
final localStorageProvider = FutureProvider<LocalStorageService>((ref) async {
  return await LocalStorageService.getInstance();
});

/// Provider for ApiClient
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(baseUrl: ApiEndpoints.baseUrl);
});

/// Provider for PhoneNumberService
final phoneNumberServiceProvider = Provider<PhoneNumberService>((ref) {
  return PhoneNumberService();
});

/// Provider for AuthRepository
/// Automatically uses MockAuthRepository when AppConfig.useMockData = true
/// Switch to real API by setting AppConfig.useMockData = false
final authRepositoryProvider = Provider<dynamic>((ref) {
  final localStorage = ref.watch(localStorageProvider).value;

  if (localStorage == null) {
    throw Exception('LocalStorage not initialized');
  }

  // Use mock data for frontend testing (no API needed)
  if (AppConfig.useMockData) {
    return MockAuthRepository(localStorage: localStorage);
  }

  // Use real API when backend is ready
  final apiClient = ref.watch(apiClientProvider);
  return AuthRepository(
    apiClient: apiClient,
    localStorage: localStorage,
  );
});
