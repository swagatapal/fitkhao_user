import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../models/order.dart';

class OrderTrackingScreen extends StatelessWidget {
  final OrderModel order;
  const OrderTrackingScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Order Tracking',
          style: TextStyle(
            fontSize: AppTypography.fontSize18,
            fontWeight: AppTypography.semiBold,
            color: AppColors.textPrimary,
            fontFamily: AppTypography.fontFamily,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.screenPaddingHorizontal,
            vertical: AppSizes.screenPaddingVertical,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _OrderSummaryCard(order: order),
              const SizedBox(height: AppSizes.spacing20),
              _buildEta(context),
              const SizedBox(height: AppSizes.spacing20),
              _buildTimeline(context),
              const SizedBox(height: AppSizes.spacing32),
              _buildHelpRow(context),
              const SizedBox(height: AppSizes.spacing20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEta(BuildContext context) {
    // Simple ETA based on stage
    final stage = order.statusStage;
    final etaText = () {
      switch (stage) {
        case OrderStatusStage.placed:
          return 'ETA ~ 40-45 mins';
        case OrderStatusStage.confirmed:
          return 'ETA ~ 35-40 mins';
        case OrderStatusStage.preparing:
          return 'ETA ~ 20-25 mins';
        case OrderStatusStage.outForDelivery:
          return 'Arriving in ~ 10 mins';
        case OrderStatusStage.delivered:
          return 'Delivered';
      }
    }();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.p16),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppSizes.radius16),
        border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.2)),
            ),
            child: const Icon(Icons.timer, color: AppColors.primaryGreen),
          ),
          const SizedBox(width: AppSizes.spacing12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Estimated Arrival',
                style: TextStyle(
                  fontSize: AppTypography.fontSize14,
                  fontWeight: AppTypography.medium,
                  color: AppColors.textSecondary,
                  fontFamily: AppTypography.fontFamily,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                etaText,
                style: const TextStyle(
                  fontSize: AppTypography.fontSize18,
                  fontWeight: AppTypography.bold,
                  color: AppColors.textPrimary,
                  fontFamily: AppTypography.fontFamily,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTimeline(BuildContext context) {
    final steps = [
      (OrderStatusStage.placed, 'Order Placed', 'We received your order'),
      (OrderStatusStage.confirmed, 'Order Confirmed', 'Restaurant confirmed your order'),
      (OrderStatusStage.preparing, 'Preparing Order', 'Chef is preparing your meal'),
      (OrderStatusStage.outForDelivery, 'Out for Delivery', 'Rider is on the way'),
      (OrderStatusStage.delivered, 'Delivered', 'Enjoy your meal!'),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.p16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius16),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: AppSizes.opacity08),
            blurRadius: AppSizes.shadowBlur12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Delivery Progress',
            style: TextStyle(
              fontSize: AppTypography.fontSize16,
              fontWeight: AppTypography.semiBold,
              color: AppColors.textPrimary,
              fontFamily: AppTypography.fontFamily,
            ),
          ),
          const SizedBox(height: AppSizes.spacing16),
          ...List.generate(steps.length, (index) {
            final s = steps[index];
            final isCompleted = order.statusStage.index > s.$1.index;
            final isCurrent = order.statusStage == s.$1;
            final isLast = index == steps.length - 1;

            return _TimelineTile(
              title: s.$2,
              subtitle: s.$3,
              isCompleted: isCompleted,
              isCurrent: isCurrent,
              showConnector: !isLast,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHelpRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.p16),
              side: const BorderSide(color: AppColors.primaryGreen),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radius12),
              ),
            ),
            icon: const Icon(Icons.support_agent, color: AppColors.primaryGreen),
            label: const Text(
              'Help & Support',
              style: TextStyle(
                fontSize: AppTypography.fontSize14,
                fontWeight: AppTypography.semiBold,
                color: AppColors.primaryGreen,
                fontFamily: AppTypography.fontFamily,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSizes.spacing12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              padding: const EdgeInsets.symmetric(vertical: AppSizes.p16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radius12),
              ),
            ),
            icon: const Icon(Icons.call, color: Colors.white),
            label: const Text(
              'Contact Rider',
              style: TextStyle(
                fontSize: AppTypography.fontSize14,
                fontWeight: AppTypography.semiBold,
                color: Colors.white,
                fontFamily: AppTypography.fontFamily,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  final OrderModel order;
  const _OrderSummaryCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.p16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius16),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: AppSizes.opacity08),
            blurRadius: AppSizes.shadowBlur12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radius12),
            child: order.restaurantImage != null
                ? Image.asset(
                    order.restaurantImage!,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                  )
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
                Text(
                  order.restaurantName,
                  style: const TextStyle(
                    fontSize: AppTypography.fontSize16,
                    fontWeight: AppTypography.semiBold,
                    color: AppColors.textPrimary,
                    fontFamily: AppTypography.fontFamily,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Order #${order.id} • ${order.items.length} items',
                  style: const TextStyle(
                    fontSize: AppTypography.fontSize14,
                    color: AppColors.textSecondary,
                    fontFamily: AppTypography.fontFamily,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  order.isDelivered
                      ? 'Delivered'
                      : _stageText(order.statusStage),
                  style: TextStyle(
                    fontSize: AppTypography.fontSize12,
                    fontWeight: AppTypography.medium,
                    color: order.isDelivered
                        ? AppColors.successColor
                        : AppColors.primaryGreen,
                    fontFamily: AppTypography.fontFamily,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  static String _stageText(OrderStatusStage stage) {
    switch (stage) {
      case OrderStatusStage.placed:
        return 'Order placed';
      case OrderStatusStage.confirmed:
        return 'Order confirmed';
      case OrderStatusStage.preparing:
        return 'Preparing your food';
      case OrderStatusStage.outForDelivery:
        return 'Out for delivery';
      case OrderStatusStage.delivered:
        return 'Delivered';
    }
  }
}

class _TimelineTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isCurrent;
  final bool showConnector;

  const _TimelineTile({
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    required this.isCurrent,
    required this.showConnector,
  });

  @override
  Widget build(BuildContext context) {
    final dotColor = isCompleted || isCurrent
        ? AppColors.primaryGreen
        : AppColors.borderColor;
    final innerIcon = isCompleted
        ? const Icon(Icons.check, size: 16, color: Colors.white)
        : isCurrent
            ? const Icon(Icons.radio_button_checked, size: 16, color: Colors.white)
            : const SizedBox.shrink();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: (isCompleted || isCurrent)
                    ? AppColors.primaryGreen
                    : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: dotColor, width: 2),
              ),
              child: Center(child: innerIcon),
            ),
            if (showConnector)
              Container(
                width: 2,
                height: 40,
                color: isCompleted
                    ? AppColors.primaryGreen
                    : AppColors.borderColor,
              ),
          ],
        ),
        const SizedBox(width: AppSizes.spacing12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: AppTypography.fontSize14,
                    fontWeight:
                        isCurrent ? AppTypography.bold : AppTypography.semiBold,
                    color: AppColors.textPrimary,
                    fontFamily: AppTypography.fontFamily,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: AppTypography.fontSize13,
                    color: AppColors.textSecondary,
                    fontFamily: AppTypography.fontFamily,
                  ),
                ),
                const SizedBox(height: AppSizes.spacing16),
              ],
            ),
          ),
        )
      ],
    );
  }
}

