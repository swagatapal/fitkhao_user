/// API endpoint constants for the FitKhao application
class ApiEndpoints {
  ApiEndpoints._();

  // Base URL - Should be moved to environment configuration
  static const String baseUrl = 'https://api.fitkhao.com/v1';

  // Authentication endpoints
  static const String sendOTP = '/auth/send-otp';
  static const String verifyOTP = '/auth/verify-otp';
  static const String resendOTP = '/auth/resend-otp';
  static const String refreshToken = '/auth/refresh-token';
  static const String logout = '/auth/logout';

  // User endpoints
  static const String userProfile = '/user/profile';
  static const String updateProfile = '/user/profile';
  static const String userAddresses = '/user/addresses';

  // Restaurant endpoints
  static const String restaurants = '/restaurants';
  static String restaurantById(String id) => '/restaurants/$id';
  static const String restaurantMenu = '/restaurants/menu';

  // Order endpoints
  static const String createOrder = '/orders';
  static const String myOrders = '/orders/my-orders';
  static String orderById(String id) => '/orders/$id';
  static String cancelOrder(String id) => '/orders/$id/cancel';

  // Payment endpoints
  static const String initiatePayment = '/payments/initiate';
  static const String verifyPayment = '/payments/verify';
  static const String paymentMethods = '/payments/methods';

  // Cart endpoints
  static const String cart = '/cart';
  static const String addToCart = '/cart/add';
  static const String updateCart = '/cart/update';
  static const String removeFromCart = '/cart/remove';
  static const String clearCart = '/cart/clear';
}
