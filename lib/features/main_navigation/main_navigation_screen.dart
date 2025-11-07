import 'package:fitkhao_user/features/auth/screens/detailed_health_info_screen.dart';
import 'package:fitkhao_user/features/delivery/presentation/screens/delivery_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_utils.dart';


class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _selectedIndex = 0;

  // List of screens
  final List<Widget> _screens =  [


    DeliveryScreen(),
    DeliveryScreen(),
    DetailedHealthInfoScreen(),
    DeliveryScreen()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Display the selected screen
          IndexedStack(
            index: _selectedIndex,
            children: _screens,
          ),

          // Floating Bottom Navigation Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomNavigationBar(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    final spacing16 = context.responsiveSpacing(16.0);
    final spacing8 = context.responsiveSpacing(8.0);

    return Padding(
      padding: EdgeInsets.only(
        left: spacing16,
        right: spacing16,
        bottom: spacing16,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEFF5EC),
          borderRadius: BorderRadius.circular(context.responsiveSpacing(50.0)),
          border: Border.all(color: AppColors.primaryGreen, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: spacing8,
            vertical: spacing8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                context: context,
                icon: Icons.delivery_dining,
                label: 'Delivery',
                index: 0,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.dashboard,
                label: 'Dashboard',
                index: 1,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.person,
                label: 'Profile',
                index: 2,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.history,
                label: 'History',
                index: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;
    final spacing10 = context.responsiveSpacing(10.0);
    final spacing4 = context.responsiveSpacing(4.0);

    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: context.responsiveSpacing(4.0)),
          padding: EdgeInsets.symmetric(
            horizontal: spacing10,
            vertical: spacing10,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(context.responsiveSpacing(30.0)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.primaryGreen,
                size: context.responsiveSpacing(24.0),
              ),
              SizedBox(height: spacing4),
              Text(
                label,
                style: TextStyle(
                  fontSize: context.responsiveFontSize(12.0),
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontFamily: 'Lato',
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
