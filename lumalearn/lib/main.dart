import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Supabase
  // REPLACE these strings with your actual keys from the Supabase Dashboard
  await Supabase.initialize(
    url: 'https://atrtsflqyrcvqjuatxya.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF0cnRzZmxxeXJjdnFqdWF0eHlhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUzNDUzMTcsImV4cCI6MjA4MDkyMTMxN30.gAG0NNMmlNiHLXk30ARSHYevtgwRy7o0XwJ-FWDUhsQ',
  );

  runApp(const ProviderScope(child: LumaLearnApp()));
}

class LumaLearnApp extends ConsumerWidget {
  const LumaLearnApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'LumaLearn',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: goRouter,
    );
  }
}