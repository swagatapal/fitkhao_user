/// Model representing a menu food item
class MenuItem {
  final String id;
  final String name;
  final String imageUrl;
  final int calories;
  final double price;
  final String category; // 'Lean Mass Gain', 'Fat Loss', 'Diet Maintain'
  final bool isVeg;
  final String description;
  final String protein; // e.g., "12g"
  final String carbs; // e.g., "40g"
  final String fats; // e.g., "8g"
  final String fiber; // e.g., "6g"
  final String menuType; // veg, non-veg, eggetarian, vegan
  final String mealType; // breakfast, lunch, dinner
  final List<String> goalCategory;
  final bool isAvailable;
  final List<String> tags;
  final List<String> allergens;
  final double rating; // Rating out of 5

  const MenuItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.calories,
    required this.price,
    required this.category,
    required this.isVeg,
    this.description = '',
    this.protein = '0g',
    this.carbs = '0g',
    this.fats = '0g',
    this.fiber = '0g',
    this.menuType = 'veg',
    this.mealType = 'lunch',
    this.goalCategory = const [],
    this.isAvailable = true,
    this.tags = const [],
    this.allergens = const [],
    this.rating = 0.0,
  });

  /// Create MenuItem from API response
  factory MenuItem.fromJson(Map<String, dynamic> json) {
    final nutritionalInfo = json['nutritionalInfo'] as Map<String, dynamic>? ?? {};
    final menuType = (json['menuType'] as String?) ?? 'veg';

    // Determine if item is vegetarian
    final isVeg = menuType.toLowerCase() == 'veg' ||
                  menuType.toLowerCase() == 'eggetarian' ||
                  menuType.toLowerCase() == 'vegan';

    // Map goal categories to UI categories
    final goalCategories = (json['goalCategory'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList() ?? [];

    // Determine primary category based on first goal
    String category = 'Diet Maintain';
    if (goalCategories.isNotEmpty) {
      final firstGoal = goalCategories.first.toLowerCase();
      if (firstGoal.contains('lean-mass') || firstGoal.contains('gain')) {
        category = 'Lean Mass Gain';
      } else if (firstGoal.contains('fat-loss')) {
        category = 'Fat Loss';
      } else if (firstGoal.contains('regular') || firstGoal.contains('maintenance')) {
        category = 'Diet Maintain';
      }
    }

    return MenuItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      imageUrl: 'https://img.freepik.com/free-photo/top-view-table-full-food_23-2149209253.jpg', // Default image
      calories: (nutritionalInfo['kcal'] as num?)?.toInt() ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      category: category,
      isVeg: isVeg,
      description: json['description'] as String? ?? '',
      protein: '${nutritionalInfo['protein'] ?? 0}g',
      carbs: '${nutritionalInfo['carbs'] ?? 0}g',
      fats: '${nutritionalInfo['fat'] ?? 0}g',
      fiber: '0g', // API doesn't provide fiber
      menuType: menuType,
      mealType: (json['mealType'] as String?) ?? 'lunch',
      goalCategory: goalCategories,
      isAvailable: json['isAvailable'] as bool? ?? true,
      tags: (json['tags'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      allergens: (json['allergens'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      rating: (json['avgRating'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // Mock data for demonstration
  static List<MenuItem> getMockMenuItems() {
    return [
      const MenuItem(
        id: '1',
        name: 'Protein Power Bowl',
        imageUrl:
            'https://img.freepik.com/free-photo/top-view-table-full-food_23-2149209253.jpg?semt=ais_hybrid&w=740&q=80',
        calories: 450,
        price: 99,
        category: 'Lean Mass Gain',
        isVeg: true,
        description: 'A wholesome blend of oats, fresh fruits, and honey for a nutritious start to your day.',
        protein: '12g',
        carbs: '40g',
        fats: '8g',
        fiber: '6g',
      ),
      const MenuItem(
        id: '2',
        name: 'Grilled Chicken Salad',
        imageUrl:
            'https://www.shutterstock.com/image-photo/fried-salmon-steak-cooked-green-600nw-2489026949.jpg',
        calories: 320,
        price: 99,
        category: 'Fat Loss',
        isVeg: false,
        description: 'Lean grilled chicken with fresh vegetables for a healthy meal.',
        protein: '25g',
        carbs: '15g',
        fats: '12g',
        fiber: '4g',
      ),
      const MenuItem(
        id: '3',
        name: 'Mediterranean Bowl',
        imageUrl:
            'https://img.freepik.com/free-photo/top-view-table-full-food_23-2149209253.jpg?semt=ais_hybrid&w=740&q=80',
        calories: 380,
        price: 99,
        category: 'Diet Maintain',
        isVeg: true,
        description: 'Balanced meal with hummus, falafel, and vegetables.',
        protein: '14g',
        carbs: '45g',
        fats: '10g',
        fiber: '8g',
      ),
      const MenuItem(
        id: '4',
        name: 'Paneer Tikka Bowl',
        imageUrl:
            'https://img.freepik.com/free-photo/top-view-table-full-food_23-2149209253.jpg?semt=ais_hybrid&w=740&q=80',
        calories: 480,
        price: 99,
        category: 'Lean Mass Gain',
        isVeg: true,
        description: 'Indian style paneer with spices and vegetables.',
        protein: '18g',
        carbs: '35g',
        fats: '20g',
        fiber: '5g',
      ),
      const MenuItem(
        id: '5',
        name: 'Tuna Salad',
        imageUrl:
            'https://www.shutterstock.com/image-photo/fried-salmon-steak-cooked-green-600nw-2489026949.jpg',
        calories: 280,
        price: 99,
        category: 'Fat Loss',
        isVeg: false,
        description: 'Fresh tuna with mixed greens.',
        protein: '30g',
        carbs: '10g',
        fats: '8g',
        fiber: '3g',
      ),
      const MenuItem(
        id: '6',
        name: 'Quinoa Buddha Bowl',
        imageUrl:
            'https://img.freepik.com/free-photo/top-view-table-full-food_23-2149209253.jpg?semt=ais_hybrid&w=740&q=80',
        calories: 360,
        price: 99,
        category: 'Diet Maintain',
        isVeg: true,
        description: 'Wholesome quinoa bowl with seasonal vegetables.',
        protein: '10g',
        carbs: '50g',
        fats: '9g',
        fiber: '7g',
      ),
    ];
  }
}
