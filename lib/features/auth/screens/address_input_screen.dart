import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/route_names.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../shared/widgets/logo_widget.dart';
import '../../../shared/widgets/primary_button.dart';
import '../providers/auth_provider.dart';

class AddressInputScreen extends ConsumerStatefulWidget {
  const AddressInputScreen({super.key});

  @override
  ConsumerState<AddressInputScreen> createState() =>
      _AddressInputScreenState();
}

class _AddressInputScreenState extends ConsumerState<AddressInputScreen> {
  final TextEditingController _buildingController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();

  final FocusNode _buildingFocusNode = FocusNode();
  final FocusNode _streetFocusNode = FocusNode();
  final FocusNode _pincodeFocusNode = FocusNode();

  String _building = '';
  String _street = '';
  String _pincode = '';
  bool _isLoadingLocation = false;

  @override
  void dispose() {
    _buildingController.dispose();
    _streetController.dispose();
    _pincodeController.dispose();
    _buildingFocusNode.dispose();
    _streetFocusNode.dispose();
    _pincodeFocusNode.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _building.isNotEmpty && _street.isNotEmpty && _pincode.length == 6;
  }

  void _handleContinue() {
    // Save address to auth provider
    ref.read(authProvider.notifier).saveAddress(
      buildingNameNumber: _building,
      street: _street,
      pincode: _pincode,
    );

    // Navigate to BMI analysis screen
    context.go(RouteNames.bmiAnalysis);
  }

  void _handleLocateOnMap() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoadingLocation = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location services are disabled. Please enable them.'),
              backgroundColor: AppColors.errorColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoadingLocation = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Location permissions are denied'),
                backgroundColor: AppColors.errorColor,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoadingLocation = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permissions are permanently denied'),
              backgroundColor: AppColors.errorColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );

      final double latitude = position.latitude;
      final double longitude = position.longitude;

      // Print to console
      debugPrint('===== DEVICE LOCATION =====');
      debugPrint('Latitude: $latitude');
      debugPrint('Longitude: $longitude');
      debugPrint('Accuracy: ${position.accuracy} meters');
      debugPrint('Timestamp: ${position.timestamp}');
      debugPrint('===========================');

      // Perform reverse geocoding to get address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        // Extract address components
        String building = place.subThoroughfare ?? place.name ?? '';
        String street = place.thoroughfare ?? place.street ?? '';
        String pincode = place.postalCode ?? '';

        debugPrint('===== REVERSE GEOCODED ADDRESS =====');
        debugPrint('Building: $building');
        debugPrint('Street: $street');
        debugPrint('Pincode: $pincode');
        debugPrint('Full Address: ${place.street}, ${place.locality}, ${place.administrativeArea}');
        debugPrint('====================================');

        // Update the form fields
        setState(() {
          _building = building;
          _street = street;
          _pincode = pincode;
          _buildingController.text = building;
          _streetController.text = '${place.street}, ${place.locality}, ${place.administrativeArea}';
          _pincodeController.text = pincode;
        });

        // Save address with location to auth provider
        ref.read(authProvider.notifier).saveAddress(
          buildingNameNumber: building,
          street: street,
          pincode: pincode,
          latitude: latitude,
          longitude: longitude,
        );

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location fetched successfully'),
              backgroundColor: AppColors.primaryGreen,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }

      setState(() {
        _isLoadingLocation = false;
      });
    } catch (e) {
      debugPrint('Error getting current location: $e');
      setState(() {
        _isLoadingLocation = false;
      });
      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to get current location: ${e.toString()}'),
            backgroundColor: AppColors.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required Function(String) onChanged,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
  }) {
    final spacing8 = context.responsiveSpacing(8.0);
    final spacing16 = context.responsiveSpacing(16.0);
    final radiusSmall = context.responsiveSpacing(4.0);
    final inputHeight = context.inputHeight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: context.responsiveFontSize(14.0),
                    fontFamily: 'Lato',
                  ),
            ),
            const SizedBox(width: 4),
            Text(
              '*',
              style: TextStyle(
                color: AppColors.errorColor,
                fontSize: context.responsiveFontSize(16.0),
              ),
            ),
          ],
        ),
        SizedBox(height: spacing8),
        TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLength: maxLength,
          onChanged: onChanged,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: context.responsiveFontSize(16.0),
                fontFamily: 'Lato',
              ),
          decoration: InputDecoration(
        hintText: label,
        hintStyle: TextStyle(
          fontSize: context.responsiveFontSize(16.0),
          color: AppColors.textSecondary,
          fontFamily: 'Lato',
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(
          horizontal: context.responsiveSpacing(20.0),
          vertical: context.responsiveSpacing(16.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            context.responsiveSpacing(4.0),
          ),
          borderSide: const BorderSide(
            color: AppColors.borderColor,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            context.responsiveSpacing(4.0),
          ),
          borderSide: const BorderSide(
            color: AppColors.primaryGreen,
            width: 1.5,
          ),
        ),
      ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get responsive values
    final horizontalPadding = context.horizontalPadding;
    final verticalPadding = context.verticalPadding;
    final spacing8 = context.responsiveSpacing(8.0);
    final spacing16 = context.responsiveSpacing(16.0);
    final spacing24 = context.responsiveSpacing(24.0);
    final spacing40 = context.responsiveSpacing(40.0);
    final spacing48 = context.responsiveSpacing(48.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: spacing40),
              // Logo
              const Center(
                child: LogoWidget(),
              ),
              SizedBox(height: spacing48),
              // Title
              Text(
                AppStrings.whereToDeliver,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: context.responsiveFontSize(22.0),
                      fontFamily: "Lato",
                    ),
              ),
              SizedBox(height: spacing8),
              // Subtitle
              Text(
                AppStrings.pleaseEnterAddress,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF2B292A),
                      fontWeight: FontWeight.w400,
                      fontSize: context.responsiveFontSize(16.0),
                      fontFamily: "Lato",
                    ),
              ),
              SizedBox(height: spacing40),
              // Building Name/Number Field
              _buildInputField(
                label: AppStrings.buildingNameNumber,
                controller: _buildingController,
                focusNode: _buildingFocusNode,
                onChanged: (value) {
                  setState(() {
                    _building = value.trim();
                  });
                },
              ),
              SizedBox(height: spacing24),
              // Street Field
              _buildInputField(
                label: AppStrings.street,
                controller: _streetController,
                focusNode: _streetFocusNode,
                onChanged: (value) {
                  setState(() {
                    _street = value.trim();
                  });
                },
              ),
              SizedBox(height: spacing24),
              // Pincode Field
              _buildInputField(
                label: AppStrings.pincode,
                controller: _pincodeController,
                focusNode: _pincodeFocusNode,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 6,
                onChanged: (value) {
                  setState(() {
                    _pincode = value.trim();
                  });
                },
              ),
              SizedBox(height: spacing8),
              // Helper text
              Text(
                AppStrings.putYourDetailedAddress,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textTertiary,
                      fontSize: context.responsiveFontSize(12.0),
                      fontFamily: 'Lato',
                    ),
              ),
              SizedBox(height: spacing24),
              // Continue Button
              PrimaryButton(
                text: AppStrings.continueText,
                textColor: Colors.white,
                onPressed: _isFormValid ? _handleContinue : null,
                isLoading: false,
                height: 50.0,
                disabledBackgroundColor: const Color(0xFFA0D488),
              ),
              SizedBox(height: spacing16),
              // Locate on Map Button
              PrimaryButton(
                height: 50,
                text: AppStrings.locateOnMap,
                onPressed: !_isLoadingLocation ? _handleLocateOnMap : null,
                textColor: AppColors.textWhite,
                backgroundColor: Color(0XFF5D9E40),
                borderRadius: 4.0,
                isLoading: _isLoadingLocation,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
