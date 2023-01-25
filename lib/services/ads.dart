import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io' show Platform;

import './purchases.dart';
import '../logging.dart';

class Ads {
  static bool isBannerAdShown = false;
  static InterstitialAd? _videoAdd;

  static void initialize() {
    MobileAds.instance.initialize();
    _loadInterstitialVideoAd();
  }

  static void _loadInterstitialVideoAd() {
    _videoAdd = null;

    InterstitialAd.load(
        adUnitId: getInterstitialVideoAdUnitId(),
        adLoadCallback:
            InterstitialAdLoadCallback(onAdLoaded: (InterstitialAd ad) {
          _videoAdd = ad;
        }, onAdFailedToLoad: (LoadAdError error) {
          Log.instance.w('InterstitialAd failed to load: $error');
        }),
        request: const AdRequest());
  }

  static String getInterstitialVideoAdUnitId() {
    return Platform.isIOS
        ? "ca-app-pub-3940256099942544/5135589807"
        : "ca-app-pub-3940256099942544/8691691433";
  }

  static void showRewardedInterstitialVideoAd(Function onClosed) async {
    if (Purchases.isNoAds()) onClosed();

    if (_videoAdd != null) {
      _videoAdd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (InterstitialAd ad) {
        _closeAdd(onClosed);
      }, onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        _closeAdd(onClosed);
        _videoAdd?.dispose();
      });

      _videoAdd!.show();
    } else {
      _closeAdd(onClosed);
    }
  }

  static void _closeAdd(Function onClosed) {
    _videoAdd?.dispose();
    _loadInterstitialVideoAd();
    onClosed();
  }
}
