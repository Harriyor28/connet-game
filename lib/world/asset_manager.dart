/// Lightweight offline asset registry. Actual procedural visuals need no files.
class AssetManager {
  final Set<String> _loadedKeys = <String>{};

  Set<String> get loadedKeys => Set.unmodifiable(_loadedKeys);

  Future<void> loadWorldAssets(Iterable<String> assetKeys) async {
    _loadedKeys.addAll(assetKeys);
  }

  bool isLoaded(String key) => _loadedKeys.contains(key);

  void unloadWorldAssets(Iterable<String> assetKeys) {
    _loadedKeys.removeAll(assetKeys);
  }

  void clear() => _loadedKeys.clear();
}
