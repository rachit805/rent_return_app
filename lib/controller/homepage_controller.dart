import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class HomePageController extends GetxController {
  RxBool isBannerAdLoaded = false.obs;
  BannerAd? bannerAd;

  @override
  void onInit() {
    super.onInit();
    initializeBannerAd();
  }

  void initializeBannerAd() {
    bannerAd = BannerAd(
      adUnitId:
          'ca-app-pub-2514113084570130/4856025877', // Replace with your actual ad unit ID
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          isBannerAdLoaded.value = true;
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          isBannerAdLoaded.value = false;
        },
      ),
    );

    bannerAd!.load();
  }

  @override
  void onClose() {
    bannerAd?.dispose();
    super.onClose();
  }

  var selectedIndex = 2.obs;
  void onItemTapped(int index) {
    selectedIndex.value = index;
  }
}
