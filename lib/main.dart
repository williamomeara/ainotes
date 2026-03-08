import 'package:flutter/material.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'core/routing/app_router.dart';
import 'core/storage/database.dart';
import 'core/storage/database_provider.dart';
import 'core/storage/migration_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize FlutterGemma with error handling
  bool gemmaInitialized = false;
  try {
    await FlutterGemma.initialize();
    gemmaInitialized = true;
    debugPrint('[AiNotes] FlutterGemma initialized successfully');
  } catch (e) {
    debugPrint('[AiNotes] FlutterGemma init failed: $e');
  }

  // Initialize database and run migration if needed
  final db = AppDatabase();
  if (await MigrationService.needsMigration()) {
    await MigrationService(db).migrate();
  }

  final prefs = await SharedPreferences.getInstance();
  final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;
  await prefs.setBool('flutter_gemma_available', gemmaInitialized);

  appRouter = createRouter(onboardingComplete: onboardingComplete);
  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
      ],
      child: const AiNotesApp(),
    ),
  );
}
