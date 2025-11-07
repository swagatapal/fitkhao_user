import 'package:fitkhao_user/core/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class DeliveryScreen extends StatelessWidget {
  const DeliveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Image.asset(
            "assets/images/coming_soon.png",
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.cover,
          ),

          Positioned(
            child: Center(
              child: Text("Coming Soon", style: TextStyle(
                 fontSize: context.responsiveFontSize(28.0),
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      fontFamily: 'Lato',
              ),),
            ),
          )
        ],
      ),
    );
  }
}
