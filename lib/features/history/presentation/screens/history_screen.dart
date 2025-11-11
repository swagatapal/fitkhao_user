import 'package:fitkhao_user/core/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../../models/order.dart';
import 'delivered_order_details_screen.dart';
import 'order_tracking_screen.dart';

enum _HistoryFilter { upcoming, delivered }

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  _HistoryFilter _selected = _HistoryFilter.upcoming;
  final TextEditingController _searchController = TextEditingController();

  // Mock orders
  late final List<OrderModel> _upcomingOrders;
  late final List<OrderModel> _deliveredOrders;

  @override
  void initState() {
    super.initState();
    _seedMockData();
  }

  void _seedMockData() {
    _upcomingOrders = [
      OrderModel(
        id: 'FK12345',
        restaurantName: 'Green Bowl Kitchen',
        restaurantImage: 'assets/images/o1.png',
        orderTime: DateTime.now().subtract(const Duration(minutes: 10)),
        deliveredTime: null,
        address: '24B, Park Street, Kolkata',
        items: const [
          OrderItemModel(name: 'Quinoa Salad', quantity: 1, price: 199),
          OrderItemModel(name: 'Avocado Toast', quantity: 1, price: 149),
        ],
        deliveryFee: 20,
        tax: 18,
        statusStage: OrderStatusStage.preparing,
      ),
      OrderModel(
        id: 'FK12346',
        restaurantName: 'Lean Grill House',
        restaurantImage: 'assets/images/o2.png',
        orderTime: DateTime.now().subtract(const Duration(minutes: 5)),
        deliveredTime: null,
        address: '24B, Park Street, Kolkata',
        items: const [
          OrderItemModel(name: 'Grilled Chicken', quantity: 1, price: 249),
          OrderItemModel(name: 'Brown Rice', quantity: 1, price: 79),
        ],
        deliveryFee: 25,
        tax: 22,
        statusStage: OrderStatusStage.outForDelivery,
      ),
    ];

    _deliveredOrders = [
      OrderModel(
        id: 'FK12001',
        restaurantName: 'FitKhao Cafe',
        restaurantImage: 'assets/images/o3.png',
        orderTime: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
        deliveredTime: DateTime.now().subtract(const Duration(days: 1, hours: 1, minutes: 20)),
        address: '24B, Park Street, Kolkata',
        items: const [
          OrderItemModel(name: 'Oats Bowl', quantity: 1, price: 129),
          OrderItemModel(name: 'Greek Yogurt', quantity: 1, price: 99),
        ],
        deliveryFee: 15,
        tax: 16,
        statusStage: OrderStatusStage.delivered,
      ),
      OrderModel(
        id: 'FK11998',
        restaurantName: 'Healthy Hub',
        restaurantImage: 'assets/images/o2.png',
        orderTime: DateTime.now().subtract(const Duration(days: 2, hours: 3)),
        deliveredTime: DateTime.now().subtract(const Duration(days: 2, hours: 2, minutes: 40)),
        address: '24B, Park Street, Kolkata',
        items: const [
          OrderItemModel(name: 'Veggie Wrap', quantity: 2, price: 99),
        ],
        deliveryFee: 20,
        tax: 12,
        statusStage: OrderStatusStage.delivered,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final orders = _selected == _HistoryFilter.upcoming
        ? _upcomingOrders
        : _deliveredOrders;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: AppSizes.spacing12),
                Padding(
                  padding:  EdgeInsets.symmetric(horizontal: AppSizes.screenPaddingHorizontal),
                  child: _buildSegmentedControl(context),
                ),
                const SizedBox(height: AppSizes.spacing12),
                Padding(
                  padding:  EdgeInsets.symmetric(horizontal: AppSizes.screenPaddingHorizontal),
                  child: _buildSearchBar(),
                ),
                const SizedBox(height: AppSizes.spacing12),

              ],
            ),
            Expanded(
              child: orders.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.screenPaddingHorizontal,
                      ),
                      itemCount: orders.length,
                      separatorBuilder: (_, __) => const SizedBox(height: AppSizes.spacing12),
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return _OrderCard(
                          order: order,
                          isUpcoming: _selected == _HistoryFilter.upcoming,
                          onTap: () {
                            if (_selected == _HistoryFilter.upcoming) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => OrderTrackingScreen(order: order),
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DeliveredOrderDetailsScreen(order: order),
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentedControl(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.p6),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF5EC),
        borderRadius: BorderRadius.circular(context.responsiveSpacing(AppSizes.radius50)),
        border: Border.all(color: AppColors.primaryGreen, width: AppSizes.borderThin),
      ),
      child: Row(
        children: [
          _SegmentChip(
            label: 'Upcoming',
            selected: _selected == _HistoryFilter.upcoming,
            onTap: () => setState(() => _selected = _HistoryFilter.upcoming),
          ),
          _SegmentChip(
            label: 'Delivered',
            selected: _selected == _HistoryFilter.delivered,
            onTap: () => setState(() => _selected = _HistoryFilter.delivered),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.history, size: 48, color: AppColors.textTertiary),
          SizedBox(height: AppSizes.spacing12),
          Text(
            'No orders to show',
            style: TextStyle(
              fontSize: AppTypography.fontSize14,
              color: AppColors.textSecondary,
              fontFamily: AppTypography.fontFamily,
            ),
          ),
        ],
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
                  "Order History",
                  style: const TextStyle(
                    fontSize: AppTypography.fontSize20,
                    fontWeight: AppTypography.bold,
                    color: AppColors.textPrimary,
                    fontFamily: 'Lato',
                  ),
                ),
                //const SizedBox(height: AppSizes.spacing2),

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


  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius4),
        border: Border.all(
          color: AppColors.textWhite,
          width: AppSizes.borderMedium,
        ),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: AppStrings.searchFood,
          hintStyle: const TextStyle(
            fontSize: AppTypography.fontSize14,
            color: AppColors.textSecondary,
            fontFamily: 'Lato',
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.textSecondary,
            size: AppSizes.icon24,
          ),
          suffixIcon: IconButton(
            icon: const Icon(
              Icons.mic,
              color: AppColors.primaryGreen,
              size: AppSizes.icon24,
            ),
            onPressed: () {
              // TODO: Implement voice search
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSizes.spacing16,
            vertical: AppSizes.spacing12,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radius4),
            borderSide: const BorderSide(
              color: AppColors.borderColor,
              width: AppSizes.borderMedium,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radius4),
            borderSide: const BorderSide(
              color: AppColors.primaryGreen,
              width: AppSizes.borderMedium,
            ),
          ),
        ),
      ),
    );
  }

}

class _SegmentChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SegmentChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.responsiveSpacing(16.0),
            vertical: context.responsiveSpacing(10.0),
          ),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(context.responsiveSpacing(AppSizes.spacing30)),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: context.responsiveFontSize(AppTypography.fontSize14),
                fontWeight: AppTypography.semiBold,
                color: selected ? Colors.white : AppColors.textPrimary,
                fontFamily: AppTypography.fontFamily,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final bool isUpcoming;
  final VoidCallback onTap;
  const _OrderCard({required this.order, required this.isUpcoming, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radius4),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radius4),
          border: Border.all(color: AppColors.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: AppSizes.opacity08),
              blurRadius: AppSizes.shadowBlur12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.p16),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.radius12),
                child: order.restaurantImage != null
                    ? Image.asset(order.restaurantImage!, width: 64, height: 64, fit: BoxFit.cover)
                    : Container(
                        width: 64,
                        height: 64,
                        color: AppColors.primaryGreen.withValues(alpha: 0.08),
                        child: const Icon(Icons.restaurant, color: AppColors.primaryGreen),
                      ),
              ),
              const SizedBox(width: AppSizes.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            order.restaurantName,
                            style: const TextStyle(
                              fontSize: AppTypography.fontSize16,
                              fontWeight: AppTypography.semiBold,
                              color: AppColors.textPrimary,
                              fontFamily: AppTypography.fontFamily,
                            ),
                          ),
                        ),
                        Icon(Icons.chevron_right, color: AppColors.textTertiary),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Order #${order.id} • ${order.items.length} items',
                      style: const TextStyle(
                        fontSize: AppTypography.fontSize13,
                        color: AppColors.textSecondary,
                        fontFamily: AppTypography.fontFamily,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (isUpcoming)
                          _statusPill(_stageText(order.statusStage), AppColors.primaryGreen)
                        else
                          _statusPill('Delivered', AppColors.successColor),
                        const Spacer(),
                        Text(
                          _formatTime(order.isDelivered ? (order.deliveredTime ?? order.orderTime) : order.orderTime),
                          style: const TextStyle(
                            fontSize: AppTypography.fontSize12,
                            color: AppColors.textTertiary,
                            fontFamily: AppTypography.fontFamily,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  static Widget _statusPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p10, vertical: AppSizes.p6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radius8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: AppTypography.fontSize12,
          fontWeight: AppTypography.semiBold,
          color: color,
          fontFamily: AppTypography.fontFamily,
        ),
      ),
    );
  }

  static String _stageText(OrderStatusStage stage) {
    switch (stage) {
      case OrderStatusStage.placed:
        return 'Placed';
      case OrderStatusStage.confirmed:
        return 'Confirmed';
      case OrderStatusStage.preparing:
        return 'Preparing';
      case OrderStatusStage.outForDelivery:
        return 'On the way';
      case OrderStatusStage.delivered:
        return 'Delivered';
    }
  }

  static String _formatTime(DateTime d) {
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    final ampm = d.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }
}
