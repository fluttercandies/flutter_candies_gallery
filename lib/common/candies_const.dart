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
  String get avatar => 'assets/images/avatars/$name.jpg';
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

const Map<String, List<String>> mds = <String, List<String>>{
  'zmtzawqlp': <String>[
    'assets/markdown/zmtzawqlp/Tools/Flutter 功能最全的JsonToDart工具(桌面Web海陆空支持).md',
    'assets/markdown/zmtzawqlp/Tools/Flutter JsonToDart 工具.md',
    'assets/markdown/zmtzawqlp/Tools/Flutter JsonToDart Mac版 lei了，真的不mark吗.md',
    'assets/markdown/zmtzawqlp/Sliver/Flutter Sliver你要的瀑布流小姐姐.md',
    'assets/markdown/zmtzawqlp/Sliver/Flutter Sliver一生之敌 (ExtendedList).md',
    'assets/markdown/zmtzawqlp/Sliver/Flutter Sliver一生之敌 (ScrollView).md',
    'assets/markdown/zmtzawqlp/Sliver/Flutter Sliver 锁住你的美.md',
    'assets/markdown/zmtzawqlp/Image/Flutter 什么功能都有的Image.md',
    'assets/markdown/zmtzawqlp/Image/Flutter 可以缩放拖拽的图片.md',
    'assets/markdown/zmtzawqlp/Image/Flutter 仿掘金微信图片滑动退出页面效果.md',
    'assets/markdown/zmtzawqlp/Image/Flutter 图片全家桶.md',
    'assets/markdown/zmtzawqlp/Image/Flutter 图片裁剪旋转翻转编辑器.md',
    'assets/markdown/zmtzawqlp/zmtzawqlp.md',
    'assets/markdown/zmtzawqlp/Text/Flutter RichText支持文本选择.md',
    'assets/markdown/zmtzawqlp/Text/Flutter RichText支持自定义文本溢出效果.md',
    'assets/markdown/zmtzawqlp/Text/Flutter RichText支持自定义文字背景.md',
    'assets/markdown/zmtzawqlp/Text/Flutter RichText支持图片显示和自定义图片效果.md',
    'assets/markdown/zmtzawqlp/Text/Flutter RichText支持特殊文字效果.md',
  ],
};
