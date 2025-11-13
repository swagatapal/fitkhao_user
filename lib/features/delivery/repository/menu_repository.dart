import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/services/local_storage_service.dart';
import '../models/menu_item.dart';

/// Repository for menu-related operations
class MenuRepository {
  final ApiClient _apiClient;
  final LocalStorageService _localStorage;

  MenuRepository({
    required ApiClient apiClient,
    required LocalStorageService localStorage,
  })  : _apiClient = apiClient,
        _localStorage = localStorage;

  /// Fetch menu items from API
  Future<List<MenuItem>> getMenuItems({String? mealType}) async {
    debugPrint('[MenuRepository] Fetching menu items...');

    try {
      // Get auth token
      final token = _localStorage.getAuthToken();
      if (token == null || token.isEmpty) {
        throw AuthException(
          message: 'Authentication required. Please login again.',
        );
      }

      // Prepare headers with Bearer token
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      // Make GET request
      final json = await _apiClient.getJson(
        '/api/food/items',
        headers: headers,
      );

      debugPrint('[MenuRepository] Menu items response: $json');

      // Parse response
      final success = json['success'] == true;
      if (!success) {
        final message = json['message'] as String? ?? 'Failed to fetch menu items';
        throw Exception(message);
      }

      final data = json['data'] as Map<String, dynamic>?;
      final items = data?['items'] as List<dynamic>? ?? [];

      // Convert to MenuItem list
      final menuItems = items
          .map((item) => MenuItem.fromJson(item as Map<String, dynamic>))
          .toList();

      // Filter by meal type if provided
      if (mealType != null && mealType.isNotEmpty) {
        return menuItems
            .where((item) =>
                item.mealType.toLowerCase() == mealType.toLowerCase())
            .toList();
      }

      debugPrint('[MenuRepository] Fetched ${menuItems.length} menu items');
      return menuItems;
    } catch (e) {
      debugPrint('[MenuRepository] Error fetching menu items: $e');
      final message = ExceptionHandler.getErrorMessage(e);
      throw Exception(message);
    }
  }
}
