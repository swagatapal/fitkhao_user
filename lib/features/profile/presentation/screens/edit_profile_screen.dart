import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:country_code_picker/country_code_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../auth/models/auth_state.dart';
import '../../../auth/providers/auth_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  // Form fields
  String _name = 'Tithi Nag';
  String _phoneNumber = '';
  String _building = '21/9 Kar Bagan Road, Chandannagar';
  String _street = '';
  String _pincode = '';
  String _countryCode = '+91';

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _buildingController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();

  // Focus nodes
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _buildingFocusNode = FocusNode();
  final FocusNode _streetFocusNode = FocusNode();
  final FocusNode _pincodeFocusNode = FocusNode();

  // Profile image
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Fetch user data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchUserData();
    });
  }

  Future<void> _fetchUserData() async {
    // Get user data from auth state
    final authState = ref.read(authProvider);

    if (authState.phoneNumber.isNotEmpty) {
      setState(() {
        _name = authState.name;
        _phoneNumber = authState.phoneNumber;
        _building = authState.buildingNameNumber;
        _street = authState.street;
        _pincode = authState.pincode;

        // Update controllers
        _nameController.text = _name;
        _phoneController.text = _phoneNumber;
        _buildingController.text = _building;
        _streetController.text = _street;
        _pincodeController.text = _pincode;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _buildingController.dispose();
    _streetController.dispose();
    _pincodeController.dispose();
    _nameFocusNode.dispose();
    _phoneFocusNode.dispose();
    _buildingFocusNode.dispose();
    _streetFocusNode.dispose();
    _pincodeFocusNode.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _name.isNotEmpty &&
        _phoneNumber.length == AppSizes.maxLengthPhone &&
        _building.isNotEmpty &&
        _street.isNotEmpty &&
        _pincode.length == AppSizes.maxLengthPincode;
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: AppSizes.imageMaxWidth.toDouble(),
        maxHeight: AppSizes.imageMaxHeight.toDouble(),
        imageQuality: AppSizes.imageQuality,
      );

      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _handleSave() async {
    // if (!_isFormValid) return;

    final authNotifier = ref.read(authProvider.notifier);
    final authState = ref.read(authProvider);

    // Update auth state with edited values
    authNotifier.saveName(_name);
    authNotifier.saveAddress(
      buildingNameNumber: _building,
      street: _street,
      pincode: _pincode,
      latitude: authState.latitude,
      longitude: authState.longitude,
    );

    // Save user profile information
    final success = await authNotifier.completeRegistration();

    if (success && mounted) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: AppColors.primaryGreen,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );

      // Navigate to preferences saved screen
      context.go(RouteNames.preferencesSaved);
    }
    // Error message will be shown via listener
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Listen for errors
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.errorColor,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });

    final spacing12 = context.responsiveSpacing(12.0);
    final spacing20 = context.responsiveSpacing(20.0);
    final spacing24 = context.responsiveSpacing(24.0);
    final spacing32 = context.responsiveSpacing(32.0);

    return Scaffold(
      backgroundColor: AppColors.primaryGreen,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with green background
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: AppSizes.headerHeight,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF5D9E40), Color(0xFF4A7D33)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Image.asset(
                    "assets/images/header_bg.png",
                    width: MediaQuery.of(context).size.width,
                    height: AppSizes.headerHeight,
                    fit: BoxFit.cover,
                  ),
                ),
            
                // Back button
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),

            // White rounded container
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  // borderRadius: BorderRadius.only(
                  //   topLeft: Radius.circular(context.responsiveSpacing(32.0)),
                  //   topRight: Radius.circular(context.responsiveSpacing(32.0)),
                  // ),
                ),
                child: authState.isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryGreen,
                        ),
                      )
                    : SingleChildScrollView(
                  padding: EdgeInsets.all(spacing24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: spacing12),

                      // Title
                      Text(
                        AppStrings.editPersonalProfile,
                        style: TextStyle(
                          fontSize: context.responsiveFontSize(18.0),
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                          fontFamily: 'Lato',
                        ),
                      ),
                      SizedBox(height: spacing12),

                      // Profile Image
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              width: AppSizes.profileImageWidth,
                              height: AppSizes.profileImageHeight,
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen.withValues(
                                  alpha: 0.2,
                                ),
                                borderRadius: BorderRadius.circular(
                                  context.responsiveSpacing(20.0),
                                ),
                                image: _profileImage != null
                                    ? DecorationImage(
                                        image: FileImage(_profileImage!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: _profileImage == null
                                  ? Icon(
                                      Icons.person,
                                      size: context.responsiveSpacing(80.0),
                                      color: AppColors.primaryGreen,
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  padding: EdgeInsets.all(
                                    context.responsiveSpacing(8.0),
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.primaryGreen,
                                      width: AppSizes.borderThick,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.photo_library,
                                    color: AppColors.primaryGreen,
                                    size: context.responsiveSpacing(12.0),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: spacing32),

                      // Name Field
                      _buildLabel('${AppStrings.name} *'),
                      SizedBox(height: spacing12),
                      _buildTextField(
                        controller: _nameController,
                        focusNode: _nameFocusNode,
                        hint: AppStrings.nameHint,
                        onChanged: (value) => setState(() => _name = value),
                        suffixIcon: _name.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: AppSizes.icon20),
                                onPressed: () {
                                  _nameController.clear();
                                  setState(() => _name = '');
                                },
                                color: AppColors.textSecondary,
                              )
                            : null,
                      ),
                      SizedBox(height: spacing12),
                      Text(
                        AppStrings.putYourFirstAndLastName,
                        style: TextStyle(
                          fontSize: context.responsiveFontSize(12.0),
                          color: AppColors.textSecondary,
                          fontFamily: 'Lato',
                        ),
                      ),
                      SizedBox(height: spacing24),

                      // Phone Number Field
                      _buildLabel('${AppStrings.phoneNumber} *'),
                      SizedBox(height: spacing12),
                      _buildPhoneField(),
                      SizedBox(height: spacing12),
                      Text(
                        AppStrings.add10DigitsOnlyProfile,
                        style: TextStyle(
                          fontSize: context.responsiveFontSize(12.0),
                          color: AppColors.textSecondary,
                          fontFamily: 'Lato',
                        ),
                      ),
                      SizedBox(height: spacing24),

                      // Building Name/Number Field
                      _buildLabel('${AppStrings.buildingNameNumber} *'),
                      SizedBox(height: spacing12),
                      _buildTextField(
                        controller: _buildingController,
                        focusNode: _buildingFocusNode,
                        hint: AppStrings.addressHint,
                        onChanged: (value) => setState(() => _building = value),
                      ),
                      SizedBox(height: spacing24),

                      // Street Field
                      _buildLabel('${AppStrings.street} *'),
                      SizedBox(height: spacing12),
                      _buildTextField(
                        controller: _streetController,
                        focusNode: _streetFocusNode,
                        hint: AppStrings.addressHint,
                        onChanged: (value) => setState(() => _street = value),
                      ),
                      SizedBox(height: spacing24),

                      // Pincode Field
                      _buildLabel('${AppStrings.pincode} *'),
                      SizedBox(height: spacing12),
                      _buildTextField(
                        controller: _pincodeController,
                        focusNode: _pincodeFocusNode,
                        hint: AppStrings.addressHint,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        onChanged: (value) => setState(() => _pincode = value),
                      ),
                      SizedBox(height: spacing12),
                      Text(
                        AppStrings.putYourDetailedAddress,
                        style: TextStyle(
                          fontSize: context.responsiveFontSize(12.0),
                          color: AppColors.textSecondary,
                          fontFamily: 'Lato',
                        ),
                      ),
                      SizedBox(height: spacing32),

                      // Save Button
                      PrimaryButton(
                        text: AppStrings.save,
                        onPressed: !authState.isLoading
                            ? _handleSave
                            : null,
                        textColor: Colors.white,
                        height: context.inputHeight,
                        isLoading: authState.isLoading,
                      ),
                      SizedBox(height: spacing20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: context.responsiveFontSize(14.0),
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        fontFamily: 'Lato',
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required Function(String) onChanged,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      style: TextStyle(
        fontSize: context.responsiveFontSize(16.0),
        color: AppColors.textPrimary,
        fontFamily: 'Lato',
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: context.responsiveFontSize(16.0),
          color: AppColors.textSecondary.withValues(alpha: 0.5),
          fontFamily: 'Lato',
        ),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: suffixIcon,
        contentPadding: EdgeInsets.symmetric(
          horizontal: context.responsiveSpacing(20.0),
          vertical: context.responsiveSpacing(16.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.responsiveSpacing(4.0)),
          borderSide: const BorderSide(
            color: AppColors.primaryGreen,
            width: AppSizes.borderMedium,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.responsiveSpacing(AppSizes.radius4)),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: AppSizes.borderThick),
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primaryGreen, width: AppSizes.borderMedium),
        borderRadius: BorderRadius.circular(context.responsiveSpacing(AppSizes.radius4)),
      ),
      child: Row(
        children: [
          // Country Code Picker
          CountryCodePicker(
            onChanged: (country) {
              setState(() {
                _countryCode = country.dialCode ?? '+91';
              });
            },
            initialSelection: 'IN',
            favorite: const ['+91', 'IN'],
            showCountryOnly: false,
            showOnlyCountryWhenClosed: false,
            alignLeft: false,
            padding: EdgeInsets.zero,
            textStyle: TextStyle(
              fontSize: context.responsiveFontSize(16.0),
              color: AppColors.textPrimary,
              fontFamily: 'Lato',
            ),
          ),

          // Vertical divider
          Container(
            width: AppSizes.dividerWidth,
            height: context.responsiveSpacing(AppSizes.dividerHeightMedium),
            color: AppColors.borderColor,
          ),

          // Phone number input
          Expanded(
            child: TextField(
              controller: _phoneController,
              focusNode: _phoneFocusNode,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(AppSizes.maxLengthPhone),
              ],
              onChanged: (value) => setState(() => _phoneNumber = value),
              style: TextStyle(
                fontSize: context.responsiveFontSize(16.0),
                color: AppColors.textPrimary,
                fontFamily: 'Lato',
              ),
              decoration: InputDecoration(
                hintText: AppStrings.phoneNumberHint,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: context.responsiveFontSize(16.0),
                                vertical: context.responsiveFontSize(16.0),
                              ),
                              counterText: '',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
