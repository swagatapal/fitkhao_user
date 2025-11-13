import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../../models/menu_item.dart';
import '../../providers/cart_provider.dart';

class FoodDetailPopup extends ConsumerWidget {
  final MenuItem menuItem;

  const FoodDetailPopup({
    super.key,
    required this.menuItem,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radius8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Food Image
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppSizes.radius8),
                  topRight: Radius.circular(AppSizes.radius8),
                ),
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppSizes.radius8),
                  topRight: Radius.circular(AppSizes.radius8),
                ),
                child: Image.network(
                  menuItem.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.primaryGreen.withValues(alpha: 0.1),
                      child: const Icon(
                        Icons.restaurant,
                        size: AppSizes.icon80,
                        color: AppColors.primaryGreen,
                      ),
                    );
                  },
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppSizes.spacing24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Food Name
                  Text(
                    menuItem.name,
                    style: const TextStyle(
                      fontSize: AppTypography.fontSize24,
                      fontWeight: AppTypography.bold,
                      color: AppColors.textPrimary,
                      fontFamily: 'Lato',
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacing8),

                  // Calories and Rating
                  Row(
                    children: [
                      Text(
                        '${AppStrings.calories} ${menuItem.calories}kcal',
                        style: const TextStyle(
                          fontSize: AppTypography.fontSize16,
                          fontWeight: AppTypography.medium,
                          color: AppColors.textSecondary,
                          fontFamily: 'Lato',
                        ),
                      ),
                      if (menuItem.rating > 0) ...[
                        const SizedBox(width: AppSizes.spacing16),
                        const Icon(
                          Icons.star,
                          size: AppSizes.icon16,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: AppSizes.spacing4),
                        Text(
                          '${menuItem.rating.toStringAsFixed(1)}/5',
                          style: const TextStyle(
                            fontSize: AppTypography.fontSize16,
                            fontWeight: AppTypography.semiBold,
                            color: AppColors.textPrimary,
                            fontFamily: 'Lato',
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSizes.spacing16),

                  // Description
                  const Text(
                    AppStrings.description,
                    style: TextStyle(
                      fontSize: AppTypography.fontSize16,
                      fontWeight: AppTypography.semiBold,
                      color: AppColors.textPrimary,
                      fontFamily: 'Lato',
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacing8),
                  Text(
                    menuItem.description,
                    style: const TextStyle(
                      fontSize: AppTypography.fontSize14,
                      fontWeight: AppTypography.regular,
                      color: AppColors.textSecondary,
                      fontFamily: 'Lato',
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacing16),

                  // Goal Category
                  if (menuItem.goalCategory.isNotEmpty) ...[
                    const Text(
                      'Goal Category',
                      style: TextStyle(
                        fontSize: AppTypography.fontSize16,
                        fontWeight: AppTypography.semiBold,
                        color: AppColors.textPrimary,
                        fontFamily: 'Lato',
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacing8),
                    Wrap(
                      spacing: AppSizes.spacing8,
                      runSpacing: AppSizes.spacing8,
                      children: menuItem.goalCategory.map((category) {
                        return _buildChip(
                          category.replaceAll('-', ' ').split(' ').map((word) =>
                            word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : word
                          ).join(' '),
                          AppColors.primaryGreen,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSizes.spacing16),
                  ],

                  // Tags
                  if (menuItem.tags.isNotEmpty) ...[
                    const Text(
                      'Tags',
                      style: TextStyle(
                        fontSize: AppTypography.fontSize16,
                        fontWeight: AppTypography.semiBold,
                        color: AppColors.textPrimary,
                        fontFamily: 'Lato',
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacing8),
                    Wrap(
                      spacing: AppSizes.spacing8,
                      runSpacing: AppSizes.spacing8,
                      children: menuItem.tags.map((tag) {
                        return _buildChip(tag, AppColors.darkGreen);
                      }).toList(),
                    ),
                    const SizedBox(height: AppSizes.spacing16),
                  ],

                  // Allergens
                  if (menuItem.allergens.isNotEmpty) ...[
                    const Text(
                      'Allergens',
                      style: TextStyle(
                        fontSize: AppTypography.fontSize16,
                        fontWeight: AppTypography.semiBold,
                        color: AppColors.textPrimary,
                        fontFamily: 'Lato',
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacing8),
                    Wrap(
                      spacing: AppSizes.spacing8,
                      runSpacing: AppSizes.spacing8,
                      children: menuItem.allergens.map((allergen) {
                        return _buildChip(allergen, AppColors.errorColor);
                      }).toList(),
                    ),
                    const SizedBox(height: AppSizes.spacing16),
                  ],

                  // Nutritional Information
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildNutritionItem(AppStrings.protein, menuItem.protein),
                      _buildNutritionItem(AppStrings.carbs, menuItem.carbs),
                      _buildNutritionItem(AppStrings.fats, menuItem.fats),
                      _buildNutritionItem(AppStrings.fiber, menuItem.fiber),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spacing24),

                  // Add to Cart Button
                  SizedBox(
                    width: double.infinity,
                    height: AppSizes.buttonHeight,
                    child: ElevatedButton(
                      onPressed: () {
                        ref.read(cartProvider.notifier).addItem(menuItem);
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radius8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.shopping_cart,
                            color: Colors.white,
                            size: AppSizes.icon20,
                          ),
                          const SizedBox(width: AppSizes.spacing8),
                          const Text(
                            AppStrings.addToCart,
                            style: TextStyle(
                              fontSize: AppTypography.fontSize16,
                              fontWeight: AppTypography.semiBold,
                              color: Colors.white,
                              fontFamily: 'Lato',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: AppTypography.fontSize12,
            fontWeight: AppTypography.regular,
            color: AppColors.textSecondary,
            fontFamily: 'Lato',
          ),
        ),
        const SizedBox(height: AppSizes.spacing4),
        Text(
          value,
          style: const TextStyle(
            fontSize: AppTypography.fontSize14,
            fontWeight: AppTypography.semiBold,
            color: AppColors.textPrimary,
            fontFamily: 'Lato',
          ),
        ),
      ],
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacing12,
        vertical: AppSizes.spacing6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radius4),
        border: Border.all(
          color: color,
          width: AppSizes.borderThin,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: AppTypography.fontSize12,
          fontWeight: AppTypography.medium,
          color: color,
          fontFamily: 'Lato',
        ),
      ),
    );
  }
}
