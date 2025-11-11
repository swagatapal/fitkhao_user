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
  });

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
