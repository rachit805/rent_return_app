import 'package:get_storage/get_storage.dart';

class GetStorageHelper {
  final _storage = GetStorage();

  // Save data
  void saveData(String key, String value) {
    _storage.write(key, value);
  }

  // Retrieve data
  String getData(String key) {
    return _storage.read(key) ?? '';
  }
}
