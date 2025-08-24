import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  // Singleton pattern to ensure only one instance of AdManager exists.
  static final AdManager _instance = AdManager._internal();
  factory AdManager() => _instance;
  AdManager._internal();

  // Placeholder for the loaded ad instance.
  InterstitialAd? _interstitialAd;
  
  // This is a placeholder for a real ad unit ID.
  // Use a real ad unit ID in your production app.
  final String _adUnitId = "ca-app-pub-1993397054354769/8836766664";

  void loadInterstitialAd() {
    debugPrint("AdManager: Attempting to load interstitial ad.");
    // In newer versions of the SDK, you may need to use nonPersonalizedAds.
    // This is another way to help ensure privacy-focused ads.
    InterstitialAd.load(
      adUnitId: _adUnitId,
      // The AdRequest constructor is the correct place for these flags.
      request: const AdRequest(
        // Set this to true to request non-personalized ads.
        nonPersonalizedAds: true,
      ),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          debugPrint("AdManager: Interstitial ad loaded successfully.");
        },
        onAdFailedToLoad: (error) {
          debugPrint("AdManager: Interstitial ad failed to load: $error");
        },
      ),
    );
  }

  void showInterstitialAd() {
    debugPrint("AdManager: Attempting to show interstitial ad.");
    // In a real app, this is where you would show the loaded ad.
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          debugPrint("AdManager: Interstitial ad dismissed.");
          ad.dispose();
          _interstitialAd = null;
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint("AdManager: Interstitial ad failed to show: $error");
          ad.dispose();
          _interstitialAd = null;
        },
      );
      _interstitialAd!.show();
    } else {
      debugPrint("AdManager: Interstitial ad is not ready to be shown.");
    }
  }
}
