import 'storage_io.dart' if (dart.library.html) 'storage_web.dart';

abstract class StorageAdapter {
  Future<void> init();
  Future<Map<String, int>> loadData();
  Future<void> saveData(int instagramCount, int tikTokCount);

  factory StorageAdapter() => getStorageAdapter();
}
