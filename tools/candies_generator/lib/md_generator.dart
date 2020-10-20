import 'dart:io';
import 'package:io/ansi.dart';
import 'package:dart_style/dart_style.dart';

void mdGo() {
  print(green.wrap('find markdown : '));
  final Directory directory = Directory('assets/markdown/');

  final Map<String, List<String>> mds = <String, List<String>>{};
  getList(directory, mds);

  final File file = File('lib/common/candies_const.dart');
  if (!file.existsSync()) {
    file.createSync();
  }
  final StringBuffer sb = StringBuffer();
  final StringBuffer pubspecSb = StringBuffer();
  sb.write('const Map<String, List<String>> mds = <String, List<String>>{');
  for (final String key in mds.keys) {
    final List<String> value = mds[key];
    String temp = '';
    for (final String p in value) {
      temp += '\'$p\',';
      pubspecSb.write('    - $p\n');
    }
    sb.write('\'$key\': <String>[$temp],');
  }

  sb.write('};');

  file.writeAsStringSync(
      DartFormatter().format(fileContent.replaceAll('{0}', sb.toString())));

  final File pubspecFile = File('pubspec.yaml');
  final String pubspec = pubspecFile.readAsStringSync();
  pubspecFile.writeAsStringSync(pubspec.replaceRange(
      pubspec.indexOf('# markdown start') + '# markdown start'.length,
      pubspec.indexOf('  # markdown end') - 1,
      '\n\n${pubspecSb.toString()}'));
}

void getList(
  Directory directory,
  Map<String, List<String>> mds,
) {
  for (final FileSystemEntity item in directory.listSync()) {
    final FileStat fileStat = item.statSync();
    if (fileStat.type == FileSystemEntityType.directory) {
      if (item.parent?.path?.endsWith('markdown') ?? false) {
        mds[item.path.replaceAll('assets/markdown/', '')] = <String>[];
      }
      getList(
        Directory(item.path),
        mds,
      );
    } else if (fileStat.type == FileSystemEntityType.file) {
      for (final String key in mds.keys) {
        if (item.path.contains(key)) {
          print(green.wrap(item.path));
          mds[key].add(item.path);
        }
      }
    }
  }
}

const String fileContent = '''
import 'dart:async' show Future;
import 'dart:collection';
import 'package:path/path.dart';
import 'package:collection/collection.dart';
import 'package:flutter_candies_gallery/common/extension/extension.dart';

class CandyChef {
  CandyChef(
    this.name,
    this.introduction,
  );

  final String name;
  final String introduction;
  final List<Category> categories = <Category>[];
  String get avatar => 'assets/images/avatars/\$name.jpg';
  String _content;
  Future<String> getIntroductionContent() async {
    return _content ??= await introduction.assetString;
  }
}

class Category {
  Category(this.type, List<String> articles) {
    if (articles != null) {
      for (final String item in articles) {
        this.articles.add(Article(basenameWithoutExtension(item), item));
      }
    }
  }
  final List<Article> articles = <Article>[];
  final String type;
}

class Article {
  Article(this.title, this.md);
  final String title;
  final String md;
  String _content;
  Future<String> getContent() async {
    return _content ??= await md.assetString;
  }
}

class CandyChiefs extends ListBase<CandyChef> {
  factory CandyChiefs() => _candyChiefs;
  CandyChiefs._() {
    for (final MapEntry<String, List<String>> entry in mds.entries) {
      final String root = entry.value.firstWhere(
          (String element) => basenameWithoutExtension(element) == entry.key);
      final CandyChef candyChef = CandyChef(entry.key, root);

      final Map<String, List<String>> group = groupBy<String, String>(
          entry.value.where((String element) => element != root),
          (String a) => split(dirname(a)).last);

      for (final String item in group.keys) {
        candyChef.categories.add(Category(item, group[item]));
      }
      add(candyChef);
    }
  }
  static final CandyChiefs _candyChiefs = CandyChiefs._();

  final List<CandyChef> _list = <CandyChef>[];
  @override
  int get length => _list.length;
  @override
  set length(int value) {
    _list.length = value;
  }

  @override
  CandyChef operator [](int index) {
    return _list[index];
  }

  @override
  void operator []=(int index, CandyChef value) {
    _list[index] = value;
  }
}

{0}

''';
