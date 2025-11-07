import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/responsive_utils.dart';

class PreferencesSavedScreen extends ConsumerStatefulWidget {
  const PreferencesSavedScreen({super.key});

  @override
  ConsumerState<PreferencesSavedScreen> createState() =>
      _PreferencesSavedScreenState();
}

class _PreferencesSavedScreenState
    extends ConsumerState<PreferencesSavedScreen> {
  @override
  void initState() {
    super.initState();
    // Auto navigate to home after 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        context.go(RouteNames.home);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final spacing24 = context.responsiveSpacing(24.0);
    final spacing32 = context.responsiveSpacing(32.0);
    final spacing48 = context.responsiveSpacing(48.0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background blurred image (placeholder)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primaryGreen.withValues(alpha: 0.1),
                    Colors.white,
                  ],
                ),
              ),
            ),
          ),

          // Success card at bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.all(spacing48),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(context.responsiveSpacing(32.0)),
                  topRight: Radius.circular(context.responsiveSpacing(32.0)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Success Icon
                  Container(
                    width: context.screenWidth * 0.4,
                    height: context.screenWidth * 0.4,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        context.responsiveSpacing(20.0),
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Folder icon
                        Icon(
                          Icons.folder_open,
                          size: context.responsiveSpacing(80.0),
                          color: AppColors.primaryGreen.withValues(alpha: 0.3),
                        ),
                        // Rocket icon
                        Positioned(
                          top: context.responsiveSpacing(20.0),
                          right: context.responsiveSpacing(20.0),
                          child: Transform.rotate(
                            angle: -0.5,
                            child: Icon(
                              Icons.rocket_launch,
                              size: context.responsiveSpacing(60.0),
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ),
                        // Checkmark
                        Positioned(
                          bottom: context.responsiveSpacing(10.0),
                          left: context.responsiveSpacing(30.0),
                          child: Icon(
                            Icons.check_circle,
                            size: context.responsiveSpacing(40.0),
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: spacing48),

                  // "Yay!" title
                  Text(
                    AppStrings.yay,
                    style: TextStyle(
                      fontSize: context.responsiveFontSize(36.0),
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      fontFamily: 'Lato',
                    ),
                  ),
                  SizedBox(height: spacing24),

                  // Success message
                  Text(
                    AppStrings.preferencesSavedTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: context.responsiveFontSize(20.0),
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      fontFamily: 'Lato',
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: spacing32),

                  // Call message
                  Text(
                    AppStrings.expectCallSoon,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: context.responsiveFontSize(16.0),
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                      fontFamily: 'Lato',
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: spacing24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
