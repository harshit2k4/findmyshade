import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_strings.dart';
import '../../data/local/favourites_box.dart';
import '../../data/local/shades_loader.dart';
import '../../data/models/brand_model.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  List<_SavedItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final savedIds = FavouritesBox.getAll();
    final brands = await ShadesLoader.load();
    final found = <_SavedItem>[];

    for (final brand in brands) {
      for (final shade in brand.shades) {
        if (savedIds.contains(shade.id)) {
          found.add(_SavedItem(shade: shade, brand: brand));
        }
      }
    }

    setState(() {
      _items = found;
      _loading = false;
    });
  }

  Future<void> _remove(String shadeId) async {
    final current = FavouritesBox.getAll()..remove(shadeId);
    await FavouritesBox.save(current);
    setState(() => _items.removeWhere((i) => i.shade.id == shadeId));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.savedTitle)),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _items.isEmpty
                ? _EmptyState(cs: cs)
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenH,
                      AppSpacing.md,
                      AppSpacing.screenH,
                      AppSpacing.xl,
                    ),
                    itemCount: _items.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.listGap),
                    itemBuilder: (_, i) => _SavedCard(
                      item: _items[i],
                      onRemove: () => _remove(_items[i].shade.id),
                      cs: cs,
                      tt: tt,
                    ),
                  ),
      ),
    );
  }
}

class _SavedItem {
  final ShadeModel shade;
  final BrandModel brand;
  const _SavedItem({required this.shade, required this.brand});
}

class _SavedCard extends StatelessWidget {
  const _SavedCard({
    required this.item,
    required this.onRemove,
    required this.cs,
    required this.tt,
  });

  final _SavedItem item;
  final VoidCallback onRemove;
  final ColorScheme cs;
  final TextTheme tt;

  Color _onColor(Color bg) =>
      bg.computeLuminance() > 0.35 ? Colors.black87 : Colors.white;

  @override
  Widget build(BuildContext context) {
    final color = item.shade.color;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant, width: 1),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Color panel
            Container(
              width: 72,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(19),
                ),
              ),
              child: Center(
                child: Text(
                  item.shade.finish,
                  style: TextStyle(
                    color: _onColor(color).withOpacity(0.85),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.cardInner),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.shade.name,
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.brand.name,
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),

            // Remove button
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.favorite_rounded),
              color: Colors.redAccent,
              tooltip: 'Remove from saved',
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.cs});
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_border_rounded,
                size: 64, color: cs.onSurfaceVariant),
            const SizedBox(height: AppSpacing.lg),
            Text('No saved shades yet',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Tap the heart on any result to save it here.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: () => Get.back(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
