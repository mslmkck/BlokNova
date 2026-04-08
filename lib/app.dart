import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'core/localization.dart';
import 'ui/screens/menu_screen.dart';

class BlockTowerApp extends ConsumerWidget {
  const BlockTowerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = ref.watch(locProvider);
    return MaterialApp(
      title: loc.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MenuScreen(),
    );
  }
}
