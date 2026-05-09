import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'app/routes.dart';
import 'app/utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Step 1: Register test device BEFORE initializing SDK ──────────────────
  // In debug mode, AdMob requires your physical device to be registered as a
  // test device when using REAL ad unit IDs. Without this, ads are silently
  // blocked to prevent invalid traffic from developers clicking their own ads.
  //
  // How to find YOUR device ID:
  //   1. Run the app once with kDebugMode logging below enabled
  //   2. Check logcat/flutter logs for a line like:
  //      "Use RequestConfiguration.Builder().setTestDeviceIds(...) to get test ads"
  //   3. Copy that ID and paste it in the list below.
  //
  // For now we use EMULATOR constant so it works immediately on emulators.
  if (kDebugMode) {
    MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        // Pixel 10 test device ID (found from logcat 2026-05-07)
        testDeviceIds: const [
          'ADA2E5CA0C7456A294255F6DE5F90C2F', // Pixel 10 (flutter run device)
          'EMULATOR',                           // Android emulators
        ],
      ),
    );
  }

  // ── Step 2: Initialize the SDK ────────────────────────────────────────────
  final initStatus = await MobileAds.instance.initialize();

  // ── Step 3: Log adapter status to console (visible in flutter run logs) ───
  if (kDebugMode) {
    final adapterStatuses = initStatus.adapterStatuses;
    adapterStatuses.forEach((adapter, status) {
      debugPrint(
        '[AdMob] Adapter: $adapter | '
        'State: ${status.state} | '
        'Desc: ${status.description}',
      );
    });
    debugPrint('[AdMob] SDK initialized. Using REAL ad unit IDs.');
    debugPrint('[AdMob] If no ads show, check logcat for your test device ID.');
  }

  // Note: Firebase Analytics requires google-services.json in android/app/
  // Uncomment after adding the file:
  // await Firebase.initializeApp();

  runApp(const GKQuizApp());
}

class GKQuizApp extends StatelessWidget {
  const GKQuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'GK Quiz – Daily Trivia',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: Routes.splash,
      getPages: Routes.pages,
    );
  }
}
