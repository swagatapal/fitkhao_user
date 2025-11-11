import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_item.dart';
import '../models/menu_item.dart';

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  /// Add item to cart
  void addItem(MenuItem menuItem) {
    final existingIndex = state.indexWhere(
      (cartItem) => cartItem.menuItem.id == menuItem.id,
    );

    if (existingIndex >= 0) {
      // Item already in cart, increase quantity
      final updatedList = [...state];
      updatedList[existingIndex] = updatedList[existingIndex].copyWith(
        quantity: updatedList[existingIndex].quantity + 1,
      );
      state = updatedList;
    } else {
      // Add new item to cart
      state = [...state, CartItem(menuItem: menuItem, quantity: 1)];
    }
  }

  /// Remove item from cart
  void removeItem(String menuItemId) {
    state = state.where((item) => item.menuItem.id != menuItemId).toList();
  }

  /// Update item quantity
  void updateQuantity(String menuItemId, int quantity) {
    if (quantity <= 0) {
      removeItem(menuItemId);
      return;
    }

    final updatedList = state.map((item) {
      if (item.menuItem.id == menuItemId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();
    state = updatedList;
  }

  /// Clear cart
  void clearCart() {
    state = [];
  }

  /// Get total items count
  int get totalItems {
    return state.fold(0, (sum, item) => sum + item.quantity);
  }

  /// Get total price
  double get totalPrice {
    return state.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  /// Check if item is in cart
  bool isInCart(String menuItemId) {
    return state.any((item) => item.menuItem.id == menuItemId);
  }

  /// Get item quantity
  int getItemQuantity(String menuItemId) {
    final item = state.firstWhere(
      (item) => item.menuItem.id == menuItemId,
      orElse: () => CartItem(
        menuItem: MenuItem(
          id: '',
          name: '',
          imageUrl: '',
          calories: 0,
          price: 0,
          category: '',
          isVeg: true,
        ),
        quantity: 0,
      ),
    );
    return item.quantity;
  }
}

/// Provider for cart management
final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

/// Provider for total items count
final cartTotalItemsProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (sum, item) => sum + item.quantity);
});

/// Provider for total price
final cartTotalPriceProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0.0, (sum, item) => sum + item.totalPrice);
});
