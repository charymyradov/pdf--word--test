import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ImageCacheService {
  static const Duration _cacheDuration = Duration(hours: 24);

  Future<String> get _cacheDir async {
    final dir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${dir.path}/image_cache');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir.path;
  }

  Future<String> saveImage(String sourcePath, {String? fileName}) async {
    final dir = await _cacheDir;
    final name = fileName ?? DateTime.now().millisecondsSinceEpoch.toString();
    final extension = sourcePath.split('.').last;
    final destPath = '$dir/$name.$extension';

    final sourceFile = File(sourcePath);
    await sourceFile.copy(destPath);

    final metadataFile = File('$destPath.meta');
    await metadataFile.writeAsString(DateTime.now().toIso8601String());

    return destPath;
  }

  Future<String?> getCachedImage(String fileName) async {
    final dir = await _cacheDir;
    final cacheDirectory = Directory(dir);
    if (!await cacheDirectory.exists()) return null;

    await for (final entity in cacheDirectory.list()) {
      if (entity is File && entity.path.contains(fileName)) {
        if (entity.path.endsWith('.meta')) continue;

        final metaFile = File('${entity.path}.meta');
        if (await metaFile.exists()) {
          final timestamp = await metaFile.readAsString();
          final cachedAt = DateTime.parse(timestamp);
          if (DateTime.now().difference(cachedAt) < _cacheDuration) {
            return entity.path;
          } else {
            await entity.delete();
            await metaFile.delete();
          }
        }
      }
    }
    return null;
  }

  Future<void> cleanExpired() async {
    final dir = await _cacheDir;
    final cacheDirectory = Directory(dir);
    if (!await cacheDirectory.exists()) return;

    await for (final entity in cacheDirectory.list()) {
      if (entity is File && entity.path.endsWith('.meta')) {
        try {
          final timestamp = await entity.readAsString();
          final cachedAt = DateTime.parse(timestamp);
          if (DateTime.now().difference(cachedAt) >= _cacheDuration) {
            final originalPath = entity.path.replaceAll('.meta', '');
            final originalFile = File(originalPath);
            if (await originalFile.exists()) {
              await originalFile.delete();
            }
            await entity.delete();
          }
        } catch (_) {
          await entity.delete();
        }
      }
    }
  }
}
