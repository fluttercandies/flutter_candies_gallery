import 'dart:io';
import 'package:io/ansi.dart';
import 'package:path/path.dart';

List<Directory> assetsGo() {
  final Directory directory = Directory('assets/');

  print(green.wrap('find assets : '));
  final List<String> assets = <String>[];
  final List<Directory> dirList = <Directory>[];
  getList(directory, assets, dirList);
  final StringBuffer pubspecSb = StringBuffer();
  for (final String asset in assets) {
    print(green.wrap(asset));
    pubspecSb.write('    - $asset\n');
  }

  final File pubspecFile = File('pubspec.yaml');
  final String pubspec = pubspecFile.readAsStringSync();
  final int start = pubspec.indexOf('# assets start');
  final int end = pubspec.indexOf('  # assets end');
  if (start < 0 || end < 0) {
    throw Exception('''
    It can't find '# assets start' or '# assets end'.
    please add following code into pubspec.yaml first.
  assets:

  # assets start
  # assets end

    ''');
  }

  pubspecFile.writeAsStringSync(pubspec.replaceRange(
      start + '# assets start'.length, end - 1, '\n\n${pubspecSb.toString()}'));
  return dirList;
}

void getList(
  Directory directory,
  List<String> images,
  List<Directory> dirList,
) {
  dirList.add(directory);

  for (final FileSystemEntity item in directory.listSync()) {
    final FileStat fileStat = item.statSync();
    if (fileStat.type == FileSystemEntityType.directory) {
      getList(
        Directory(item.path),
        images,
        dirList,
      );
    } else if (fileStat.type == FileSystemEntityType.file) {
      if (basename(item.path) != '.DS_Store') {
        images.add(item.path);
      }
    }
  }
}
