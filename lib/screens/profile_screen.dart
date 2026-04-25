import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../services/cache_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/formatters.dart';
import '../utils/providers.dart';
import '../widgets/status_badge.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: dashboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Could not load profile')),
        data: (data) => _ProfileBody(ref: ref, context: context, data: data),
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  final WidgetRef ref;
  final BuildContext context;
  final dynamic data;

  const _ProfileBody({
    required this.ref,
    required this.context,
    required this.data,
  });

  @override
  Widget build(BuildContext ctx) {
    final client = data.client;

    return ListView(
      children: [
        // ── Header card ────────────────────────────────────────────
        Container(
          width: double.infinity,
          color: AppColors.green900,
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.green700,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    client.name.isNotEmpty ? client.name[0].toUpperCase() : 'U',
                    style: AppTextStyles.h1.copyWith(
                      color: Colors.white,
                      fontSize: 32,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                client.name,
                style: AppTextStyles.h1.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              StatusBadge(client.status),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // ── Info section ───────────────────────────────────────────
        _Section(
          title: 'Contact',
          children: [
            _InfoRow(icon: Icons.phone_outlined, label: 'Phone', value: client.phone),
            _InfoRow(icon: Icons.location_on_outlined, label: 'Address', value: client.address),
          ],
        ),

        _Section(
          title: 'Subscription',
          children: [
            _InfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Plan',
              value: client.plan == 'monthly' ? 'Monthly' : 'Annual',
            ),
            _InfoRow(
              icon: Icons.map_outlined,
              label: 'Zone',
              value: client.zone,
            ),
            _InfoRow(
              icon: Icons.local_shipping_outlined,
              label: 'Collection Day',
              value: client.collectionDay,
            ),
            if (client.paidThrough != null)
              _InfoRow(
                icon: Icons.event_available_outlined,
                label: 'Paid Through',
                value: formatDate(client.paidThrough!),
              ),
            _InfoRow(
              icon: Icons.person_add_alt_outlined,
              label: 'Member Since',
              value: formatDate(client.createdAt),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // ── Logout ─────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: OutlinedButton.icon(
            icon: const Icon(Icons.logout, color: AppColors.danger),
            label: Text(
              'Log out',
              style: AppTextStyles.label.copyWith(color: AppColors.danger),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.danger),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              final token = ref.read(authTokenProvider);
              if (token != null) await AuthService.logout(token);
              await CacheService.clear();
              ref.read(authTokenProvider.notifier).state = null;
              if (context.mounted) context.go('/login');
            },
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
          child: Text(
            title.toUpperCase(),
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textMuted,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1)
                  const Divider(height: 1, indent: 56),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.green700),
          const SizedBox(width: 12),
          Text(label, style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
          const Spacer(),
          Text(value, style: AppTextStyles.label.copyWith(color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
