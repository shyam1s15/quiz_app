import 'package:get/get.dart';
import '../models/quiz_result.dart';
import '../services/ad_service.dart';
import '../services/analytics_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class ResultController extends GetxController {
  late QuizResult result;
  InterstitialAd? _interstitialAd;
  final RxBool adLoaded = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is QuizResult) {
      result = args;
    }
    _loadInterstitial();
  }

  void _loadInterstitial() {
    AdService.loadInterstitial(
      onLoaded: (ad) {
        _interstitialAd = ad;
        adLoaded.value = true;
        // Show interstitial after a short delay on result screen
        Future.delayed(const Duration(milliseconds: 500), showInterstitial);
      },
      onFailed: (msg) {
        // AI Error Log: interstitial failed to load
        // ignore: avoid_print
        print('[AI Log] Interstitial failed: $msg');
      },
    );
  }

  void showInterstitial() {
    if (_interstitialAd != null) {
      AnalyticsService.logAdViewed(adType: 'interstitial');
      _interstitialAd!.show();
      _interstitialAd = null;
    }
  }

  @override
  void onClose() {
    _interstitialAd?.dispose();
    super.onClose();
  }
}
