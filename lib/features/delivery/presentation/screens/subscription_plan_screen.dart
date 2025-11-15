import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/logo_widget.dart';
import 'subscription_checkout_screen.dart';

class SubscriptionPlanScreen extends ConsumerStatefulWidget {
  const SubscriptionPlanScreen({super.key});

  @override
  ConsumerState<SubscriptionPlanScreen> createState() =>
      _SubscriptionPlanScreenState();
}

class _SubscriptionPlanScreenState
    extends ConsumerState<SubscriptionPlanScreen> {
  String _selectedPlan = '7'; // '7' or '30' days

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.screenPaddingHorizontal,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSizes.spacing20),
                      _buildFitKhaoLogo(),
                      const SizedBox(height: AppSizes.spacing16),
                      _buildPlanCard(
                        days: '7',
                        title: '7 Days Plan',
                        price: '₹2399',
                        meals: 'Upto 21 meals',
                        subtitle: 'The weekly Kickstart to experience FitKhao',
                      ),
                      const SizedBox(height: AppSizes.spacing16),
                      _buildPlanCard(
                        days: '30',
                        title: '30 Days Plan',
                        price: '₹7999',
                        meals: 'Upto 90 meals',
                        subtitle: 'Save more with monthly subscription',
                      ),
                      const SizedBox(height: AppSizes.spacing24),
                      _buildWhyFitKhaoSection(),
                      const SizedBox(height: AppSizes.spacing24),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.p20,
        vertical: AppSizes.spacing8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: AppSizes.shadowBlur10,
            offset: const Offset(0, AppSizes.spacing2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.all(AppSizes.spacing8),
              decoration: BoxDecoration(
                color: AppColors.darkGreen,
                borderRadius: BorderRadius.circular(AppSizes.radius8),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: AppColors.textWhite,
                size: AppSizes.icon24,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Choose your plan",
                  style: const TextStyle(
                    fontSize: AppTypography.fontSize20,
                    fontWeight: AppTypography.bold,
                    color: AppColors.textPrimary,
                    fontFamily: 'Lato',
                  ),
                ),
                //const SizedBox(height: AppSizes.spacing2),
                Text(
                 "Select the plan that fits your goal",
                  style: const TextStyle(
                    fontSize: AppTypography.fontSize12,
                    fontWeight: AppTypography.regular,
                    color: AppColors.textSecondary,
                    fontFamily: 'Lato',
                  ),
                ),
              ],
            ),
          ),
          CircleAvatar(
            radius: AppSizes.spacing24,
            backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.1),
            backgroundImage: const NetworkImage(
              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTFcyssMbcvEkMiCDu8zrO9VuN-Yy1aW1vycA&s",
            ),
            onBackgroundImageError: (exception, stackTrace) {},
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryGreen.withValues(alpha: 0.3),
                  width: AppSizes.borderThin,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFitKhaoLogo() {
    return LogoWidget();
  }

  Widget _buildPlanCard({
    required String days,
    required String title,
    required String price,
    required String meals,
    required String subtitle,
  }) {
    final isSelected = _selectedPlan == days;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlan = days;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(AppSizes.spacing16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radius8),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGreen
                : AppColors.borderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: AppTypography.fontSize16,
                      fontWeight: AppTypography.bold,
                      color: AppColors.primaryGreen,
                      fontFamily: 'Lato',
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacing8),
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: AppTypography.fontSize20,
                      fontWeight: AppTypography.bold,
                      color: AppColors.textPrimary,
                      fontFamily: 'Lato',
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacing8),
                  Text(
                    meals,
                    style: const TextStyle(
                      fontSize: AppTypography.fontSize14,
                      fontWeight: AppTypography.semiBold,
                      color: AppColors.textPrimary,
                      fontFamily: 'Lato',
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacing4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: AppTypography.fontSize12,
                      fontWeight: AppTypography.regular,
                      color: AppColors.textSecondary,
                      fontFamily: 'Lato',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSizes.spacing16),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radius12),
              child: Image.network(
                'https://img.freepik.com/free-photo/top-view-table-full-food_23-2149209253.jpg?semt=ais_hybrid&w=740&q=80',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radius12),
                    ),
                    child: const Icon(
                      Icons.restaurant_menu,
                      size: AppSizes.icon32,
                      color: AppColors.primaryGreen,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhyFitKhaoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Why FitKhao ?',
          style: TextStyle(
            fontSize: AppTypography.fontSize20,
            fontWeight: AppTypography.semiBold,
            color: AppColors.primaryGreen,
            fontFamily: 'Lato',
          ),
        ),
        const SizedBox(height: AppSizes.spacing16),
        _buildBenefitItem('Personalized Nutritionist'),
        const SizedBox(height: AppSizes.spacing8),
        _buildBenefitItem('Customized Meal Preference'),
        const SizedBox(height: AppSizes.spacing8),
        _buildBenefitItem('3 Meals Per Day'),
        const SizedBox(height: AppSizes.spacing8),
        _buildBenefitItem('Free Delivery'),
      ],
    );
  }

  Widget _buildBenefitItem(String text) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.darkGreen,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSizes.spacing12),
        Text(
          text,
          style: const TextStyle(
            fontSize: AppTypography.fontSize14,
            fontWeight: AppTypography.medium,
            color: AppColors.textPrimary,
            fontFamily: 'Lato',
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: AppSizes.buttonHeight,
        child: ElevatedButton(
          onPressed: () {
            // Navigate to checkout screen with selected plan details
            final planPrice = _selectedPlan == '7' ? '₹2399' : '₹7999';
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SubscriptionCheckoutScreen(
                  planDays: _selectedPlan,
                  planPrice: planPrice,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radius4),
            ),
            elevation: 2,
          ),
          child: Text(
            'Buy $_selectedPlan Days Plan',
            style: const TextStyle(
              fontSize: AppTypography.fontSize16,
              fontWeight: AppTypography.semiBold,
              fontFamily: 'Lato',
            ),
          ),
        ),
      ),
    );
  }
}
