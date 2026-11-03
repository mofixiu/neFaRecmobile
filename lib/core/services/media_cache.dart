import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Demo photos for exercises that are not bundled: fetched once from the
/// public-domain free-exercise-db, then kept on the phone for offline use.
class MediaCache {
  MediaCache._();
  static final instance = MediaCache._();

  static const _base = 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/';

  Directory? _dir;
  final _inFlight = <String, Future<File?>>{};

  Future<Directory> _folder() async {
    final existing = _dir;
    if (existing != null) return existing;
    final support = await getApplicationSupportDirectory();
    final dir = Directory('${support.path}/media');
    await dir.create(recursive: true);
    return _dir = dir;
  }

  /// Already on the phone, without touching the network.
  Future<File?> cached(String imagePath) async {
    final f = File('${(await _folder()).path}/${imagePath.replaceAll('/', '__')}');
    return await f.exists() ? f : null;
  }

  /// The file for [imagePath] (like `Plank/0.jpg`), downloading it if needed.
  /// Null when offline and not cached yet.
  Future<File?> fetch(String imagePath) => _inFlight.putIfAbsent(imagePath, () async {
    try {
      final hit = await cached(imagePath);
      if (hit != null) return hit;
      final client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
      try {
        final req = await client.getUrl(Uri.parse('$_base$imagePath'));
        final res = await req.close();
        if (res.statusCode != 200) return null;
        final bytes = await res.fold<List<int>>([], (a, b) => a..addAll(b));
        final f = File('${(await _folder()).path}/${imagePath.replaceAll('/', '__')}');
        await f.writeAsBytes(bytes, flush: true);
        return f;
      } finally {
        client.close();
      }
    } catch (_) {
      return null;
    } finally {
      _inFlight.remove(imagePath);
    }
  });

  /// Bytes used by downloaded demos.
  Future<int> size() async {
    final dir = await _folder();
    var total = 0;
    await for (final f in dir.list()) {
      if (f is File) total += await f.length();
    }
    return total;
  }

  Future<void> clear() async {
    final dir = await _folder();
    if (await dir.exists()) await dir.delete(recursive: true);
    _dir = null;
  }
}
