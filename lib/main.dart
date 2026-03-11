import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/theme/app_theme.dart';
import 'core/constants/app_routes.dart';
import 'core/theme/app_transitions.dart';
import 'features/home/home_screen.dart';
import 'features/skin_tone/skin_tone_screen.dart';
import 'features/brands/brands_screen.dart';
import 'features/results/results_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp(const FindMyShadeApp());
}

class FindMyShadeApp extends StatelessWidget {
  const FindMyShadeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Find My Shade',
      debugShowCheckedModeBanner: false,

      // Material 3 themes
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system, // follows device setting

      initialRoute: AppRoutes.home,
      transitionDuration: const Duration(milliseconds: 320),
      getPages: [
        GetPage(
          name: AppRoutes.home,
          page: () => const HomeScreen(),
          customTransition: SlideTransitionPage(),
        ),
        GetPage(
          name: AppRoutes.skinTone,
          page: () => const SkinToneScreen(),
          customTransition: SlideTransitionPage(),
        ),
        GetPage(
          name: AppRoutes.brands,
          page: () => const BrandsScreen(),
          customTransition: SlideTransitionPage(),
        ),
        GetPage(
          name: AppRoutes.results,
          page: () => const ResultsScreen(),
          customTransition: SlideTransitionPage(),
        ),
      ],
    );
  }
}
