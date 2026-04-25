import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/dashboard_data.dart';
import '../models/collection.dart';
import '../models/invoice.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/formatters.dart';
import '../utils/providers.dart';
import '../widgets/reru_card.dart';
import '../widgets/status_badge.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Account')),
      body: dashboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(onRetry: () => ref.refresh(dashboardProvider)),
        data: (data) => _DashboardBody(data: data),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  final DashboardData data;
  const _DashboardBody({required this.data});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {},
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _GreetingCard(data: data),
          const SizedBox(height: 12),
          if (data.nextCollection != null) ...[
            _NextCollectionCard(collection: data.nextCollection!),
            const SizedBox(height: 12),
          ],
          if (data.pendingInvoice != null) ...[
            _PendingInvoiceCard(invoice: data.pendingInvoice!),
            const SizedBox(height: 12),
          ],
          if (data.overdueInvoiceCount > 0) ...[
            _OverdueBanner(count: data.overdueInvoiceCount),
            const SizedBox(height: 12),
          ],
          _QuickActions(),
          const SizedBox(height: 12),
          _RecentCollections(collections: data.recentCollections),
        ],
      ),
    );
  }
}

class _GreetingCard extends StatelessWidget {
  final DashboardData data;
  const _GreetingCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final firstName = data.client.name.split(' ').first;
    return ReruCard(
      backgroundColor: AppColors.green900,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hello, $firstName',
                style: AppTextStyles.h2.copyWith(color: Colors.white),
              ),
              StatusBadge(data.client.status),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            data.client.zone,
            style: AppTextStyles.caption.copyWith(color: AppColors.green200),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatChip(
                label: 'Plan',
                value: data.client.plan == 'monthly' ? 'Monthly' : 'Annual',
              ),
              const SizedBox(width: 8),
              if (data.client.paidThrough != null)
                _StatChip(
                  label: 'Paid through',
                  value: formatDate(data.client.paidThrough!),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.green700,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.green200, fontSize: 10)),
          Text(value, style: AppTextStyles.label.copyWith(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}

class _NextCollectionCard extends StatelessWidget {
  final Collection collection;
  const _NextCollectionCard({required this.collection});

  @override
  Widget build(BuildContext context) {
    return ReruCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.green100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.local_shipping_outlined, color: AppColors.green700),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Next collection', style: AppTextStyles.overline),
                const SizedBox(height: 2),
                Text(
                  formatDayOfWeek(collection.scheduledDate),
                  style: AppTextStyles.cardTitle,
                ),
              ],
            ),
          ),
          Text(
            daysUntil(collection.scheduledDate),
            style: AppTextStyles.label.copyWith(color: AppColors.green700),
          ),
        ],
      ),
    );
  }
}

class _PendingInvoiceCard extends StatelessWidget {
  final Invoice invoice;
  const _PendingInvoiceCard({required this.invoice});

  @override
  Widget build(BuildContext context) {
    return ReruCard(
      backgroundColor: AppColors.warningBg,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.receipt_outlined, color: AppColors.warningText),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Payment due', style: AppTextStyles.overline.copyWith(color: AppColors.warningText)),
                const SizedBox(height: 2),
                Text(
                  formatCurrency(invoice.total),
                  style: AppTextStyles.cardTitle,
                ),
                Text(invoice.id, style: AppTextStyles.caption),
              ],
            ),
          ),
          StatusBadge(invoice.status),
        ],
      ),
    );
  }
}

class _OverdueBanner extends StatelessWidget {
  final int count;
  const _OverdueBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    return ReruCard(
      backgroundColor: AppColors.errorBg,
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.errorText),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$count overdue invoice${count > 1 ? 's' : ''}. Contact support.',
              style: AppTextStyles.body.copyWith(color: AppColors.errorText),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.history,
            label: 'Collections',
            onTap: () => context.go('/collections'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            icon: Icons.receipt_long_outlined,
            label: 'Invoices',
            onTap: () => context.go('/invoices'),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: ReruCard(
        child: Column(
          children: [
            Icon(icon, color: AppColors.green700, size: 28),
            const SizedBox(height: 8),
            Text(label, style: AppTextStyles.label),
          ],
        ),
      ),
    );
  }
}

class _RecentCollections extends StatelessWidget {
  final List<Collection> collections;
  const _RecentCollections({required this.collections});

  @override
  Widget build(BuildContext context) {
    if (collections.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text('Recent collections', style: AppTextStyles.cardTitle),
        ),
        ...collections.take(5).map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ReruCard(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        formatDayOfWeek(c.scheduledDate),
                        style: AppTextStyles.body,
                      ),
                    ),
                    StatusBadge(c.status),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 48, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text('Could not load data', style: AppTextStyles.cardTitle),
          const SizedBox(height: 4),
          Text('Check your connection and try again.', style: AppTextStyles.body),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
