import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/collection.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/formatters.dart';
import '../utils/providers.dart';
import '../widgets/reru_card.dart';
import '../widgets/status_badge.dart';

class CollectionsScreen extends ConsumerStatefulWidget {
  const CollectionsScreen({super.key});

  @override
  ConsumerState<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends ConsumerState<CollectionsScreen> {
  String? _statusFilter;

  @override
  Widget build(BuildContext context) {
    final collectionsAsync = ref.watch(collectionsProvider(_statusFilter));

    return Scaffold(
      appBar: AppBar(title: const Text('Collections')),
      body: Column(
        children: [
          _FilterBar(
            selected: _statusFilter,
            onChanged: (v) => setState(() => _statusFilter = v),
          ),
          Expanded(
            child: collectionsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Could not load collections', style: AppTextStyles.body),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () => ref.refresh(collectionsProvider(_statusFilter)),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (collections) => collections.isEmpty
                  ? _EmptyState(filter: _statusFilter)
                  : _CollectionList(collections: collections),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onChanged;
  const _FilterBar({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final filters = [
      (null, 'All'),
      ('scheduled', 'Scheduled'),
      ('completed', 'Completed'),
      ('missed', 'Missed'),
    ];
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((f) {
            final isSelected = selected == f.$1;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(f.$2),
                selected: isSelected,
                onSelected: (_) => onChanged(f.$1),
                selectedColor: AppColors.green100,
                checkmarkColor: AppColors.green700,
                labelStyle: AppTextStyles.label.copyWith(
                  color: isSelected ? AppColors.green700 : AppColors.textSecondary,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _CollectionList extends StatelessWidget {
  final List<Collection> collections;
  const _CollectionList({required this.collections});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: collections.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _CollectionTile(collection: collections[i]),
    );
  }
}

class _CollectionTile extends StatelessWidget {
  final Collection collection;
  const _CollectionTile({required this.collection});

  @override
  Widget build(BuildContext context) {
    return ReruCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _iconBg(collection.status),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_icon(collection.status), color: _iconColor(collection.status), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(formatDayOfWeek(collection.scheduledDate), style: AppTextStyles.body),
                if (collection.bagsCollected != null)
                  Text(
                    '${collection.bagsCollected} bag${collection.bagsCollected! > 1 ? 's' : ''} collected',
                    style: AppTextStyles.caption,
                  ),
              ],
            ),
          ),
          StatusBadge(collection.status),
        ],
      ),
    );
  }

  static Color _iconBg(String status) => switch (status) {
    'completed' => AppColors.successBg,
    'missed'    => AppColors.errorBg,
    _           => AppColors.infoBg,
  };

  static Color _iconColor(String status) => switch (status) {
    'completed' => AppColors.successText,
    'missed'    => AppColors.errorText,
    _           => AppColors.infoText,
  };

  static IconData _icon(String status) => switch (status) {
    'completed' => Icons.check_circle_outline,
    'missed'    => Icons.cancel_outlined,
    _           => Icons.schedule,
  };
}

class _EmptyState extends StatelessWidget {
  final String? filter;
  const _EmptyState({this.filter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_shipping_outlined, size: 48, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(
            filter != null ? 'No $filter collections' : 'No collections yet',
            style: AppTextStyles.cardTitle,
          ),
        ],
      ),
    );
  }
}
