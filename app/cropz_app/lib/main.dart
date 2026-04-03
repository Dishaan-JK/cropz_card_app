import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone_email_auth/phone_email_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'shared/core/config/supabase_config.dart';
import 'shared/presentation/providers/theme_mode_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  PhoneEmail.initializeApp(clientId: '18298794129116369409');
  final persistedThemeMode = await loadPersistedThemeMode();

  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  }

  runApp(
    ProviderScope(
      overrides: [
        initialThemeModeProvider.overrideWithValue(persistedThemeMode),
      ],
      child: const CropzApp(),
    ),
  );
}
