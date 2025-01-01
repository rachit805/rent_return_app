import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class HomePageController extends GetxController {
  final int initialPage;
  late final RxInt selectedIndex;

  HomePageController({required this.initialPage}) {
    // Properly initialize `selectedIndex` here
    selectedIndex = RxInt(initialPage);
  }

  void onItemTapped(int index) {
    selectedIndex.value = index;
  }

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
          'ca-app-pub-3940256099942544/6300978111', // Google's test ad unit ID
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
}
