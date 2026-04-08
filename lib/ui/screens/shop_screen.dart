import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants.dart';
import '../../core/localization.dart';
import '../../providers/game_provider.dart';

class SkinItem {
  final String id;
  final int price;
  final List<Color> previewColors;
  final IconData icon;

  const SkinItem({
    required this.id,
    required this.price,
    required this.previewColors,
    required this.icon,
  });
}

class PowerUpItem {
  final String id;
  final String type;
  final int price;
  final IconData icon;
  final Color color;

  const PowerUpItem({
    required this.id,
    required this.type,
    required this.price,
    required this.icon,
    required this.color,
  });
}

const List<PowerUpItem> allPowerUps = [
  PowerUpItem(
    id: 'slowMo',
    type: 'slowMo',
    price: 150,
    icon: Icons.slow_motion_video,
    color: Colors.lightBlueAccent,
  ),
  PowerUpItem(
    id: 'expand',
    type: 'expand',
    price: 250,
    icon: Icons.unfold_more,
    color: AppColors.success,
  ),
  PowerUpItem(
    id: 'magnet',
    type: 'magnet',
    price: 400,
    icon: Icons.auto_fix_high,
    color: AppColors.secondary,
  ),
];

const List<SkinItem> allSkins = [
  SkinItem(
    id: 'default',
    price: 0,
    previewColors: [Color(0xFF6C5CE7), Color(0xFF00B894), Color(0xFFE17055)],
    icon: Icons.view_in_ar,
  ),
  SkinItem(
    id: 'classic',
    price: 100,
    previewColors: [Color(0xFF2D3436), Color(0xFF636E72), Color(0xFFB2BEC3)],
    icon: Icons.square_rounded,
  ),
  SkinItem(
    id: 'hologram',
    price: 500,
    previewColors: [Color(0xFF00F5FF), Color(0xFFBF00FF), Color(0xFF39FF14)],
    icon: Icons.blur_on,
  ),
  SkinItem(
    id: 'ice',
    price: 1000,
    previewColors: [Color(0xFFE0F7FA), Color(0xFF80DEEA), Color(0xFF4DD0E1)],
    icon: Icons.ac_unit,
  ),
];

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  String _skinName(String id, Loc loc) {
    switch (id) {
      case 'default': return loc.skinDefault;
      case 'classic': return loc.skinClassic;
      case 'hologram': return loc.skinHologram;
      case 'ice': return loc.skinIce;
      default: return id;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(playerStatsProvider);
    final loc = ref.watch(locProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.background, Color(0xFF1a1a2e)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, loc, stats.coins),
              Expanded(
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      TabBar(
                        indicatorColor: AppColors.primary,
                        labelColor: AppColors.textPrimary,
                        unselectedLabelColor: AppColors.textSecondary,
                        tabs: [
                          Tab(text: loc.skins),
                          Tab(text: 'YETENEKLER'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            // Skins Tab
                            Padding(
                              padding: const EdgeInsets.all(AppDimensions.paddingM),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final double maxWidth = constraints.maxWidth > 600 ? 600 : constraints.maxWidth;
                                  return Center(
                                    child: SizedBox(
                                      width: maxWidth,
                                      child: ListView.builder(
                                        itemCount: allSkins.length,
                                        itemBuilder: (context, index) {
                                          return _buildSkinShopCard(context, ref, allSkins[index], stats, loc, index);
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            // Power-ups Tab
                            Padding(
                              padding: const EdgeInsets.all(AppDimensions.paddingM),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final double maxWidth = constraints.maxWidth > 600 ? 600 : constraints.maxWidth;
                                  return Center(
                                    child: SizedBox(
                                      width: maxWidth,
                                      child: ListView.builder(
                                        itemCount: allPowerUps.length,
                                        itemBuilder: (context, index) {
                                          return _buildPowerUpShopCard(context, ref, allPowerUps[index], stats, loc);
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Loc loc, int coins) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              loc.shop,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.warning.withAlpha(30),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.warning.withAlpha(100)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on, color: AppColors.warning, size: 20),
                const SizedBox(width: 4),
                Text(
                  '$coins',
                  style: const TextStyle(
                    color: AppColors.warning,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2);
  }

  Widget _buildSkinShopCard(
    BuildContext context,
    WidgetRef ref,
    SkinItem skin,
    dynamic stats,
    Loc loc,
    int index,
  ) {
    final isUnlocked = stats.unlockedSkins.contains(skin.id);
    final isActive = stats.activeSkin == skin.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive 
            ? AppColors.success.withAlpha(200) 
            : AppColors.primary.withAlpha( isActive ? 200 : 30),
          width: isActive ? 2 : 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.success.withAlpha(40),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ]
            : [],
      ),
      child: Row(
        children: [
          // Preview: 3 colored mini-blocks
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: skin.previewColors.map((c) {
                return Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: c.withAlpha(80),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _skinName(skin.id, loc),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (isActive)
                   Text(
                    loc.equipped,
                    style: const TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ),
          _buildActionButton(context, ref, skin, isUnlocked, isActive, loc),
        ],
      ),
    )
    .animate()
    .fadeIn(delay: Duration(milliseconds: 100 * index))
    .slideX(begin: 0.1);
  }

  Widget _buildActionButton(
    BuildContext context,
    WidgetRef ref,
    SkinItem skin,
    bool isUnlocked,
    bool isActive,
    Loc loc,
  ) {
    if (isActive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.success.withAlpha(30),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          loc.equipped,
          style: const TextStyle(color: AppColors.success, fontSize: 13, fontWeight: FontWeight.bold),
        ),
      );
    }

    if (isUnlocked) {
      return ElevatedButton(
        onPressed: () {
          ref.read(playerStatsProvider.notifier).equipSkin(skin.id);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(loc.equip, style: const TextStyle(fontSize: 13)),
      );
    }

    // Not unlocked — buy button
    return ElevatedButton.icon(
      onPressed: () async {
        final success = await ref.read(playerStatsProvider.notifier).buySkin(skin.id, skin.price);
        if (!success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loc.notEnoughCoins),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      icon: const Icon(Icons.monetization_on, size: 16, color: AppColors.warning),
      label: Text('${skin.price}', style: const TextStyle(fontSize: 13)),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        side: BorderSide(color: AppColors.warning.withAlpha(80)),
      ),
    );
  }

  Widget _buildPowerUpShopCard(BuildContext context, WidgetRef ref, PowerUpItem item, dynamic stats, Loc loc) {
    String description = '';
    int currentCount = 0;
    if (item.type == 'slowMo') {
       description = 'Zamanı 5 saniye yavaşlatır.';
       currentCount = stats.slowMoCount;
    } else if (item.type == 'expand') {
       description = 'Bloğu orijinal genişliğine döndürür.';
       currentCount = stats.expandCount;
    } else if (item.type == 'magnet') {
       description = 'Bloğu anında merkeze kilitler.';
       currentCount = stats.magnetCount;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: item.color.withAlpha(50)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: item.color.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: item.color, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.id.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                ),
                Text(description, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text('Stok: $currentCount', style: TextStyle(fontSize: 11, color: item.color.withAlpha(200), fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final success = await ref.read(playerStatsProvider.notifier).buyPowerUp(item.type, item.price);
              if (!success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(loc.notEnoughCoins), backgroundColor: AppColors.error),
                );
              }
            },
            icon: const Icon(Icons.monetization_on, size: 16, color: AppColors.warning),
            label: Text('${item.price}'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.background,
              foregroundColor: AppColors.textPrimary,
              side: const BorderSide(color: Colors.white10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1);
  }
}
