import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../utils/constants.dart';

class AdService {
  // ── Banner Ad ──────────────────────────────────────────────
  static BannerAd createBanner({
    required Function onLoaded,
    required Function onFailed,
  }) {
    if (kDebugMode) {
      debugPrint('[AdService] Loading Banner | ID: ${AdConstants.bannerAdUnitId}');
    }

    final banner = BannerAd(
      adUnitId: AdConstants.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (kDebugMode) debugPrint('[AdService] ✅ Banner loaded');
          onLoaded();
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          // Log error code + message so we can diagnose
          if (kDebugMode) {
            debugPrint(
              '[AdService] ❌ Banner FAILED | '
              'Code: ${error.code} | '
              'Message: ${error.message} | '
              'Domain: ${error.domain}',
            );
            _printAdTroubleshootingTip(error.code);
          }
          onFailed(error.message);
        },
      ),
    );
    banner.load();
    return banner;
  }

  // ── Interstitial Ad ─────────────────────────────────────────
  static void loadInterstitial({
    required Function(InterstitialAd ad) onLoaded,
    required Function(String message) onFailed,
  }) {
    if (kDebugMode) {
      debugPrint('[AdService] Loading Interstitial | ID: ${AdConstants.interstitialAdUnitId}');
    }

    InterstitialAd.load(
      adUnitId: AdConstants.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          if (kDebugMode) debugPrint('[AdService] ✅ Interstitial loaded');
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) => ad.dispose(),
            onAdFailedToShowFullScreenContent: (ad, error) {
              if (kDebugMode) {
                debugPrint('[AdService] ❌ Interstitial show FAILED | Code: ${error.code} | ${error.message}');
              }
              ad.dispose();
            },
          );
          onLoaded(ad);
        },
        onAdFailedToLoad: (error) {
          if (kDebugMode) {
            debugPrint(
              '[AdService] ❌ Interstitial FAILED | '
              'Code: ${error.code} | '
              'Message: ${error.message} | '
              'Domain: ${error.domain}',
            );
            _printAdTroubleshootingTip(error.code);
          }
          onFailed(error.message);
        },
      ),
    );
  }

  // ── Rewarded Ad ─────────────────────────────────────────────
  static void loadRewarded({
    required Function(RewardedAd ad) onLoaded,
    required Function(String message) onFailed,
  }) {
    if (kDebugMode) {
      debugPrint('[AdService] Loading Rewarded | ID: ${AdConstants.rewardedAdUnitId}');
    }

    RewardedAd.load(
      adUnitId: AdConstants.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          if (kDebugMode) debugPrint('[AdService] ✅ Rewarded loaded');
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) => ad.dispose(),
            onAdFailedToShowFullScreenContent: (ad, error) {
              if (kDebugMode) {
                debugPrint('[AdService] ❌ Rewarded show FAILED | Code: ${error.code} | ${error.message}');
              }
              ad.dispose();
            },
          );
          onLoaded(ad);
        },
        onAdFailedToLoad: (error) {
          if (kDebugMode) {
            debugPrint(
              '[AdService] ❌ Rewarded FAILED | '
              'Code: ${error.code} | '
              'Message: ${error.message} | '
              'Domain: ${error.domain}',
            );
            _printAdTroubleshootingTip(error.code);
          }
          onFailed(error.message);
        },
      ),
    );
  }

  // ── Error Code Troubleshooting ───────────────────────────────
  static void _printAdTroubleshootingTip(int code) {
    final tips = {
      0:  'ERROR_CODE_INTERNAL_ERROR – AdMob SDK internal error. Try hot-restart.',
      1:  'ERROR_CODE_INVALID_REQUEST – Check your Ad Unit ID format (ca-app-pub-XXXX/YYYY).',
      2:  'ERROR_CODE_NETWORK_ERROR – No internet or firewall blocking AdMob.',
      3:  'ERROR_CODE_NO_FILL – No ad available right now. New ad units take 24–48h. '
          'Also, register your device as a test device to guarantee fill.',
    };
    final tip = tips[code] ?? 'Unknown error code $code. Check AdMob console.';
    debugPrint('[AdService] 💡 TIP: $tip');
  }
}
