import 'package:flutter/material.dart';
import 'package:table_game/main.dart';
import 'package:table_game/pages/game_page.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class PlayMenu extends StatefulWidget {
  const PlayMenu({super.key});

  @override
  State<PlayMenu> createState() => _PlayMenuState();
}

class _PlayMenuState extends State<PlayMenu> with TickerProviderStateMixin {
  final List<int> _selectedNumbers = [];

  bool _isLoadingAd = false;
  bool _adRequired = false;
  bool _adWatched = false; // New state variable to track if the ad has been watched
  bool _isAdReady = false;

  static const String adUnitId7to12 = 'ca-app-pub-1993397054354769/3551816244';

  RewardedAd? _rewardedAd7to12;
  RewardedAd? _rewardedAd13to20;

  @override
  void initState() {
    super.initState();
    final RequestConfiguration requestConfiguration = RequestConfiguration(
      tagForChildDirectedTreatment: TagForChildDirectedTreatment.yes,
      maxAdContentRating: MaxAdContentRating.g,
    );
    MobileAds.instance.updateRequestConfiguration(requestConfiguration);

    _loadRewardedAd(adUnitId7to12, (ad) => _rewardedAd7to12 = ad);
  }

  @override
  void dispose() {
    _rewardedAd7to12?.dispose();
    _rewardedAd13to20?.dispose();
    super.dispose();
  }

  void _toggleNumber(int number) {
    setState(() {
      if (_selectedNumbers.contains(number)) {
        _selectedNumbers.remove(number);
      } else {
        _selectedNumbers.add(number);
      }
      
      // The ad is only required if a number greater than 6 is selected.
      // This is the core logic for the ad requirement.
      _adRequired = _selectedNumbers.any((num) => num > 6);
      
      // Update ad readiness status only if an ad is required and not yet watched.
      if (_adRequired && !_adWatched) {
        final bool is7to12Selected = _selectedNumbers.any((num) => num >= 7 && num <= 12);
        final bool is13to20Selected = _selectedNumbers.any((num) => num >= 13 && num <= 20);

        if (is7to12Selected && _rewardedAd7to12 != null) {
          _isAdReady = true;
        } else if (is13to20Selected && _rewardedAd13to20 != null) {
          _isAdReady = true;
        } else {
          _isAdReady = false;
        }
      } else {
        _isAdReady = false;
      }
    });
  }

  void _loadRewardedAd(String adUnitId, Function(RewardedAd) onAdLoaded) {
    setState(() {
      _isLoadingAd = true;
    });

    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          debugPrint('$ad loaded.');
          setState(() {
            onAdLoaded(ad);
            _isLoadingAd = false;
            if (_adRequired && !_adWatched) {
              _isAdReady = true;
            }
          });
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('RewardedAd failed to load: $error');
          setState(() {
            _isLoadingAd = false;
            _isAdReady = false;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Failed to load ad. Please check your internet connection and try again.'),
                duration: Duration(seconds: 3),
              ),
            );
          });
        },
      ),
    );
  }

  void _showRewardedAd(RewardedAd? ad) {
    if (ad == null) {
      debugPrint('Warning: attempt to show rewarded ad before it was loaded.');
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) => debugPrint('$ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        debugPrint('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        setState(() {
          _isAdReady = false;
        });
        if (ad.adUnitId == adUnitId7to12) {
          _loadRewardedAd(adUnitId7to12, (loadedAd) => _rewardedAd7to12 = loadedAd);
        }
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        setState(() {
          _isAdReady = false;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to show ad. Please try again.'),
              duration: Duration(seconds: 2),
            ),
          );
        });
      },
    );

    ad.show(
      onUserEarnedReward: (ad, reward) {
        debugPrint('User earned reward: ${reward.amount} ${reward.type}');
        // Once the user earns the reward, set the adWatched flag to true.
        setState(() {
          _adWatched = true;
        });
      },
    );
  }

  void _startGameInternal() {
    _selectedNumbers.sort();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GamePage(selectedNumbers: _selectedNumbers),
      ),
    );
  }

  void _handleButtonPress() {
    if (_selectedNumbers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one number to start.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Check if an ad is required and if the user has watched it.
    if (_adRequired && !_adWatched) {
      final bool is7to12Selected = _selectedNumbers.any((number) => number >= 7 && number <= 12);
      final bool is13to20Selected = _selectedNumbers.any((number) => number >= 13 && number <= 20);
      
      if (is7to12Selected && _rewardedAd7to12 != null) {
        _showRewardedAd(_rewardedAd7to12);
      } else if (is13to20Selected && _rewardedAd13to20 != null) {
        _showRewardedAd(_rewardedAd13to20);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ad is not ready. Please try again in a moment.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      // If no ad is required or the ad has been watched, start the game.
      _startGameInternal();
    }
  }

  Widget _buildNumberButton(int number) {
    final isSelected = _selectedNumbers.contains(number);
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: ElevatedButton(
        onPressed: () => _toggleNumber(number),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? lightPurple : beige,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          minimumSize: const Size(50, 50),
        ),
        child: Text(
          number.toString(),
          style: TextStyle(
            color: isSelected ? Colors.white : darkPurple,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    Widget buttonContent;
    VoidCallback? onPressed;
    Color textColor = darkPurple;
    bool isAnyNumberSelected = _selectedNumbers.isNotEmpty;

    if (!isAnyNumberSelected) {
      // Case 1: No numbers selected
      buttonContent = const Text(
        'Start Game',
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      );
      onPressed = null;
    } else if (_adRequired && !_adWatched) {
      // Case 2: Ad is required and not yet watched
      if (_isLoadingAd) {
        buttonContent = const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: darkPurple),
            SizedBox(width: 15),
            Text(
              'Loading Ad...',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ],
        );
        onPressed = null;
      } else if (_isAdReady) {
        buttonContent = const Text(
          'Watch Ad',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        );
        onPressed = _handleButtonPress;
      } else {
        buttonContent = const Text(
          'Ad not ready',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        );
        onPressed = null;
      }
    } else {
      // Case 3: Ad is not required OR Ad has been watched
      buttonContent = const Text(
        'Start Game',
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      );
      onPressed = _handleButtonPress;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: SizedBox(
        key: ValueKey<String>(onPressed != null ? 'enabled' : 'disabled'),
        width: double.infinity,
        height: 70,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: onPressed != null ? beige : beige.withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
          ),
          child: DefaultTextStyle(
            style: TextStyle(color: textColor),
            child: buttonContent,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkPurple,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Select Tables',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: SingleChildScrollView(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 10,
                          runSpacing: 10,
                          children: List.generate(6, (index) => _buildNumberButton(index + 1)),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Ad required for tables above 6',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Divider(
                            color: Colors.white,
                            thickness: 1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 10,
                          runSpacing: 10,
                          children: List.generate(14, (index) => _buildNumberButton(index + 7)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              _buildBottomButton(),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
