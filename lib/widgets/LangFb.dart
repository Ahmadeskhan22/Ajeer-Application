import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../provider/app_provider.dart';
import '../models/SeekerProfile.dart';
import '../models/Job.dart';
import '../Theme/app_theme.dart';
import '../Translations/translations.dart';

//  2. LANGUAGE TOGGLE FAB
//
//  Small floating button fixed bottom-left.
//  Toggles the entire app between Arabic (RTL) and English (LTR).
//  Positioned above the bottom nav so it never overlaps it.
//
//  Usage (wrap screen body in a Stack):
//    Stack(children: [
//      YourScrollView(),
//      const LangFab()

class LangFb extends StatelessWidget {
  // const LangFab({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();

    // TODO: implement build
    return Positioned(
      bottom: 80,
      left: 16,
      child: FloatingActionButton.small(
        heroTag: 'lang_fab',
        onPressed: prov.toggleLang,
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primary,
        elevation: 4,
        tooltip: prov.isAr ? 'Switch to English' : 'التبديل إلى العربية',
        child: Text(
          prov.isAr ? 'EN' : 'ع',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
        ),
      ),
    );
  }
}
