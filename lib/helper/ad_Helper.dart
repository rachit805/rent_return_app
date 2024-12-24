import 'dart:io';

class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-2514113084570130/6604453325";
    } else if (Platform.isIOS) {
      return "<ios_Banner_ad_id>";
    } else {
      throw UnsupportedError("Unsopported platform");
    }
  }
}
