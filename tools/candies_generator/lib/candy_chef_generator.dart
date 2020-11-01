import 'dart:io';
import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart';

List<Directory> mdGo() {
  //print(green.wrap('find markdown : '));
  final Directory directory = Directory('assets/CandyChef/');

  final Map<String, List<String>> mds = <String, List<String>>{};
    final List<Directory> dirList = <Directory>[];
  getList(directory, mds,dirList);

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
  return dirList;
}

void getList(
  Directory directory,
  Map<String, List<String>> mds,
   List<Directory> dirList,
) {
  dirList.add(directory);
  for (final FileSystemEntity item in directory.listSync()) {
    final FileStat fileStat = item.statSync();
    if (fileStat.type == FileSystemEntityType.directory) {
      if (item.parent?.path?.endsWith('CandyChef') ?? false) {
        mds[item.path.replaceAll('assets/CandyChef/', '')] = <String>[];
      }
      getList(
        Directory(item.path),
        mds,
        dirList,
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
