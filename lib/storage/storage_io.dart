import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'storage_adapter.dart';

class StorageIO implements StorageAdapter {
  @override
  Future<void> init() async {
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.request().isGranted) {
        // Access granted
      } else if (await Permission.storage.request().isGranted) {
        // Legacy access granted
      }
    }
  }

  Future<String> _getHpDirectory() async {
    if (Platform.isAndroid) {
      return '/storage/emulated/0/Documents/hp';
    }
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/hp';
  }

  @override
  Future<Map<String, int>> loadData() async {
    int instagramCount = 0;
    int tikTokCount = 0;
    try {
      final hpPath = await _getHpDirectory();
      final hpDir = Directory(hpPath);
      // We don't check for legacy file here because init() is called first usually, 
      // but let's be safe and replicate the logic fully if needed.
      // Actually, let's keep it simple: load from the file. Assuming init handles directory creation if needed?
      // No, loadData handles reading.

      // Legacy file handling (porting from main.dart)
      final oldFile = File(hpPath);
      if (await oldFile.exists()) {
        try {
          final contents = await oldFile.readAsString();
          final parts = contents.split(',');
          if (parts.length == 2) {
             instagramCount = int.parse(parts[0]);
             tikTokCount = int.parse(parts[1]);
          }
          await oldFile.delete();
        } catch (e) {
          debugPrint('Error migrating legacy file: $e');
        }
      }

      if (await hpDir.exists()) {
        final file = File('${hpDir.path}/data.txt');
        if (await file.exists()) {
          final contents = await file.readAsString();
          final parts = contents.split(',');
          if (parts.length == 2) {
            instagramCount = int.parse(parts[0]);
            tikTokCount = int.parse(parts[1]);
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
    }
    return {
      'instagram': instagramCount,
      'tiktok': tikTokCount,
    };
  }

  @override
  Future<void> saveData(int instagramCount, int tikTokCount) async {
    try {
      final hpPath = await _getHpDirectory();
      final hpDir = Directory(hpPath);
      
      // Ensure directory exists
      if (!await hpDir.exists()) {
        await hpDir.create(recursive: true);
      }
      
      final file = File('${hpDir.path}/data.txt');
      await file.writeAsString('$instagramCount,$tikTokCount');
    } catch (e) {
      debugPrint('Error saving data: $e');
    }
  }
}

StorageAdapter getStorageAdapter() => StorageIO();
