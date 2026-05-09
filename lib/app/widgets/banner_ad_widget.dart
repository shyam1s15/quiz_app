import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';
import '../services/analytics_service.dart';
import '../utils/theme.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _banner;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _banner = AdService.createBanner(
      onLoaded: () {
        if (mounted) {
          setState(() => _isLoaded = true);
          AnalyticsService.logAdViewed(adType: 'banner');
        }
      },
      onFailed: (String msg) {
        // AI Error Log entry: banner failed
        // ignore: avoid_print
        print('[AI Log] Banner ad failed: $msg');
      },
    );
  }

  @override
  void dispose() {
    _banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _banner == null) {
      return const SizedBox(height: 50);
    }
    return Container(
      height: _banner!.size.height.toDouble(),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.divider, width: 0.5)),
      ),
      child: AdWidget(ad: _banner!),
    );
  }
}
