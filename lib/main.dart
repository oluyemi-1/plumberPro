import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'services/diagnostics_service.dart';
import 'services/expense_service.dart';
import 'services/inventory_service.dart';
import 'services/job_template_service.dart';
import 'services/notifications_service.dart';
import 'services/pro_entitlement.dart';
import 'services/progress_service.dart';
import 'services/quote_service.dart';
import 'services/reminder_service.dart';
import 'services/srs_service.dart';
import 'services/theme_service.dart';
import 'services/tts_service.dart';
import 'services/user_profile_service.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Diagnostics first so any later init issue lands in the log.
  await DiagnosticsService.instance.ensureLoaded();
  await TtsService.instance.ensureInitialised();
  await UserProfileService.instance.ensureLoaded();
  await ProgressService.instance.ensureLoaded();
  await SrsService.instance.ensureLoaded();
  await ThemeService.instance.ensureLoaded();
  await JobTemplateService.instance.ensureLoaded();
  await ExpenseService.instance.ensureLoaded();
  await NotificationsService.instance.ensureInitialised();
  await ReminderService.instance.ensureLoaded();
  await QuoteService.instance.ensureLoaded();
  await InventoryService.instance.ensureLoaded();
  await ProEntitlement.instance.ensureLoaded();
  // Count today's app-open for streak tracking.
  await ProgressService.instance.recordOpenToday();
  runApp(const PipeSmartApp());
}

class PipeSmartApp extends StatelessWidget {
  const PipeSmartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeService.instance,
      builder: (context, _) => MaterialApp(
        title: 'PipeSmart',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        darkTheme: buildDarkAppTheme(),
        themeMode: ThemeService.instance.mode,
        home: const SplashScreen(),
      ),
    );
  }
}
