import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/local_storage_service.dart';
import '../services/phone_number_service.dart';
import '../network/api_client.dart';
import '../../features/auth/repository/auth_repository.dart';

/// Provider for LocalStorageService
final localStorageProvider = FutureProvider<LocalStorageService>((ref) async {
  return await LocalStorageService.getInstance();
});

/// Provider for PhoneNumberService
final phoneNumberServiceProvider = Provider<PhoneNumberService>((ref) {
  return PhoneNumberService();
});

/// Provider for ApiClient
final apiClientProvider = Provider<ApiClient>((ref) {
  return const ApiClient();
});

/// Provider for AuthRepository
/// Handles authentication with local storage and remote API
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final localStorage = ref.watch(localStorageProvider).value;
  final apiClient = ref.watch(apiClientProvider);

  if (localStorage == null) {
    throw Exception('LocalStorage not initialized');
  }

  return AuthRepository(localStorage: localStorage, apiClient: apiClient);
});
