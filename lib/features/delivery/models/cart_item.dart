import 'menu_item.dart';

/// Model representing an item in the cart
class CartItem {
  final MenuItem menuItem;
  final int quantity;

  const CartItem({
    required this.menuItem,
    required this.quantity,
  });

  CartItem copyWith({
    MenuItem? menuItem,
    int? quantity,
  }) {
    return CartItem(
      menuItem: menuItem ?? this.menuItem,
      quantity: quantity ?? this.quantity,
    );
  }

  double get totalPrice => menuItem.price * quantity;
}
