import 'dart:async';
import 'dart:io';

typedef AssetsChanged = void Function();

class Watcher {
  Watcher(this.dirList, this.assetsChanged);

  Watcher.single(Directory dir, this.assetsChanged)
      : dirList = <Directory>[dir];

  /// all of the directory with yaml.
  final List<Directory> dirList;

  final AssetsChanged assetsChanged;

  bool _watching = false;

  /// when the directory is change
  /// refresh the code
  StreamSubscription<FileSystemEvent> _watch(FileSystemEntity file) {
    if (FileSystemEntity.isWatchSupported) {
      return file.watch().listen((FileSystemEvent data) {
        if (data.isDirectory) {
          final Directory directory = Directory(data.path);
          _watch(directory);
          dirList.add(directory);
        } else {
          print('\n${data.path} is changed.\n');
          assetsChanged?.call();
        }
      });
    }
    return null;
  }

  /// watch all of path
  Future<void> startWatch() async {
    if (_watching) {
      return;
    }
    _watching = true;
    for (final Directory dir in dirList) {
      final StreamSubscription<FileSystemEvent> sub = _watch(dir);
      if (sub != null) {
        sub.onDone(sub.cancel);
      }
      watchMap[dir] = sub;
    }

    print('watching your assets now !');
  }

  void stopWatch() {
    _watching = false;
    for (final StreamSubscription<FileSystemEvent> v in watchMap.values) {
      v.cancel();
    }

    watchMap.clear();
  }

  Map<FileSystemEntity, StreamSubscription<FileSystemEvent>> watchMap =
      <FileSystemEntity, StreamSubscription<FileSystemEvent>>{};

  void removeAllWatches() {
    for (final StreamSubscription<FileSystemEvent> sub in watchMap.values) {
      sub?.cancel();
    }
  }
}
