import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/responsive_utils.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double? height;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? disabledBackgroundColor;
  final double? borderRadius;
  final Color? borderColor;
  final double? borderWidth;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.height,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.disabledBackgroundColor,
    this.borderRadius,
    this.borderColor,
    this.borderWidth,
  });

  @override
  Widget build(BuildContext context) {
    // Get responsive button height based on screen size
    final buttonHeight = height ?? context.buttonHeight;
    final spacing = context.responsiveSpacing(8.0);
    final fontSize = context.responsiveFontSize(16.0);
    final iconSize = context.isSmallMobile ? 18.0 : 20.0;
    final loadingSize = context.isSmallMobile ? 20.0 : 24.0;

    return SizedBox(
      width: width ?? double.infinity,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Color(0xFF5D9E40),
          disabledBackgroundColor: disabledBackgroundColor,
          foregroundColor: textColor ?? AppColors.buttonTextPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              borderRadius ?? AppSizes.radiusSmall,
            ),
            side: borderColor != null
                ? BorderSide(
                    color: borderColor!,
                    width: borderWidth ?? 1.5,
                  )
                : BorderSide.none,
          ),
          textStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: loadingSize,
                width: loadingSize,
                child: const CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.textWhite,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  
                  Flexible(
                    child: Center(
                      child: Text(
                        text,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontFamily: "Lato",
                          fontSize: 14,
                          fontWeight: FontWeight.w600
                        ),
                      ),
                    ),
                  ),
 SizedBox(width: spacing),
                  if (icon != null) ...[
                    SizedBox(
                      width: iconSize,
                      height: iconSize,
                      child: icon!,
                    ),
                   
                  ],
                ],
              ),
      ),
    );
  }
}
