import 'package:shared_preferences/shared_preferences.dart';
import 'storage_adapter.dart';

class StorageWeb implements StorageAdapter {
  @override
  Future<void> init() async {
    // SharedPreferences is initialized lazily, no explicit init needed usually, 
    // but we might want to ensure it's ready.
  }

  @override
  Future<Map<String, int>> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final instagramCount = prefs.getInt('instagram_count') ?? 0;
    final tikTokCount = prefs.getInt('tiktok_count') ?? 0;
    return {
      'instagram': instagramCount,
      'tiktok': tikTokCount,
    };
  }

  @override
  Future<void> saveData(int instagramCount, int tikTokCount) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('instagram_count', instagramCount);
    await prefs.setInt('tiktok_count', tikTokCount);
  }
}

StorageAdapter getStorageAdapter() => StorageWeb();
