import 'dart:io';
import 'package:io/ansi.dart';

void imageGo() {
  final Directory directory = Directory('assets/images/');

  print(green.wrap('find image : '));
  final List<String> images = <String>[];
  getList(directory, images);
  final StringBuffer pubspecSb = StringBuffer();
  for (final String image in images) {
    print(green.wrap(image));
    pubspecSb.write('    - $image\n');
  }

  final File pubspecFile = File('pubspec.yaml');
  final String pubspec = pubspecFile.readAsStringSync();
  pubspecFile.writeAsStringSync(pubspec.replaceRange(
      pubspec.indexOf('# images start') + '# markdown start'.length,
      pubspec.indexOf('  # images end') - 1,
      '\n\n${pubspecSb.toString()}'));
}

void getList(
  Directory directory,
  List<String> images,
) {
  for (final FileSystemEntity item in directory.listSync()) {
    final FileStat fileStat = item.statSync();
    if (fileStat.type == FileSystemEntityType.directory) {
      getList(
        Directory(item.path),
        images,
      );
    } else if (fileStat.type == FileSystemEntityType.file) {
      images.add(item.path);
    }
  }
}
