import 'dart:io';
import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart';

void mdGo() {
  //print(green.wrap('find markdown : '));
  final Directory directory = Directory('assets/CandyChef/');

  final Map<String, List<String>> mds = <String, List<String>>{};
  getList(directory, mds);

  final File file = File('lib/common/candies_const.dart');
  if (!file.existsSync()) {
    file.createSync();
  }
  final StringBuffer sb = StringBuffer();
  sb.write(
      'const Map<String, List<String>> candyConsts = <String, List<String>>{');
  for (final String key in mds.keys) {
    final List<String> value = mds[key];
    String temp = '';
    for (final String p in value) {
      temp += '\'$p\',';
    }
    sb.write('\'$key\': <String>[$temp],');
  }

  sb.write('};');

  file.writeAsStringSync(DartFormatter().format(sb.toString()));
}

void getList(
  Directory directory,
  Map<String, List<String>> mds,
) {
  for (final FileSystemEntity item in directory.listSync()) {
    final FileStat fileStat = item.statSync();
    if (fileStat.type == FileSystemEntityType.directory) {
      if (item.parent?.path?.endsWith('CandyChef') ?? false) {
        mds[item.path.replaceAll('assets/CandyChef/', '')] = <String>[];
      }
      getList(
        Directory(item.path),
        mds,
      );
    } else if (fileStat.type == FileSystemEntityType.file) {
      for (final String key in mds.keys) {
        if (item.path.contains(key) && basename(item.path) != '.DS_Store') {
          mds[key].add(item.path);
        }
      }
    }
  }
}
