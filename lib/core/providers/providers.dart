import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/local_storage_service.dart';
import '../services/phone_number_service.dart';
import '../../features/auth/repository/auth_repository.dart';

/// Provider for LocalStorageService
final localStorageProvider = FutureProvider<LocalStorageService>((ref) async {
  return await LocalStorageService.getInstance();
});

/// Provider for PhoneNumberService
final phoneNumberServiceProvider = Provider<PhoneNumberService>((ref) {
  return PhoneNumberService();
});

/// Provider for AuthRepository
/// Handles authentication with local storage - no network calls
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final localStorage = ref.watch(localStorageProvider).value;

  if (localStorage == null) {
    throw Exception('LocalStorage not initialized');
  }

  return AuthRepository(localStorage: localStorage);
});
