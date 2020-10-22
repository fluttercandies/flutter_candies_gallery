import 'dart:async' show Future;
import 'dart:collection';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_candies_gallery/common/candies_const.dart';
import 'package:flutter_candies_gallery/http/pub_api.dart';
import 'package:flutter_candies_gallery/model/package_info.dart';
import 'package:flutter_candies_gallery/model/package_metrics.dart';
import 'package:flutter_candies_gallery/model/package_score.dart';
import 'package:path/path.dart';
import 'package:collection/collection.dart';
import 'package:flutter_candies_gallery/common/extension/extension.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class CandyChef {
  CandyChef(
    this.name,
    this.introduction,
    this.candies,
  );

  final String name;
  final String introduction;
  final List<Category> categories = <Category>[];
  final Candies candies;
  String get avatar => 'assets/images/avatars/$name.jpg';
  String _content;
  Future<String> getIntroductionContent() async {
    await candies?.getCandies();
    return _content ??= await introduction.assetString;
  }
}

class Candies extends ListBase<Candy> {
  Candies(this.path);
  final String path;
  final List<Candy> _candies = <Candy>[];
  Future<List<Candy>> getCandies() async {
    if (path == null || isNotEmpty) {
      return this;
    }

    final String list = await path.assetString;
    final List<String> names = list.split('\n');
    for (final String name in names) {
      if (name.isNotEmpty) {
        add(Candy(name));
      }
    }

    return this;
  }

  @override
  int get length => _candies.length;
  @override
  set length(int value) {
    _candies.length = value;
  }

  @override
  Candy operator [](int index) {
    return _candies[index];
  }

  @override
  void operator []=(int index, Candy value) {
    _candies[index] = value;
  }
}

class Candy {
  Candy(this.name);
  final String name;
  TextSpan _description;
  Future<TextSpan> getDescription() async {
    if (_description == null) {
      final PackageInfo info = await PubApi().getInfo(name);
      final Pubspec pubspec = info.latest.pubspec;
      final PackageMetrics metrics = await PubApi().getSMetrics(name);
      final PackageScore score = metrics.score;
      final DateTime time = DateTime.tryParse(info.latest.published);
      final bool hasDart = metrics.scorecard.derivedTags.firstWhere(
              (String element) => element.toLowerCase().contains('dart'),
              orElse: () => null) !=
          null;
      final bool hasFlutter = metrics.scorecard.derivedTags.firstWhere(
              (String element) => element.toLowerCase().contains('flutter'),
              orElse: () => null) !=
          null;
      final bool supportWeb = metrics.scorecard.derivedTags.firstWhere(
              (String element) => element.toLowerCase().contains('web'),
              orElse: () => null) !=
          null;
      final bool supportNative = metrics.scorecard.derivedTags.firstWhere(
              (String element) => element.toLowerCase().contains('native'),
              orElse: () => null) !=
          null;

      final List<String> platforms = metrics.scorecard.derivedTags
          .where((String element) => element.contains('platform'))
          .map<String>((String e) => e.replaceAll('platform:', ''))
          .toList();

      final String dart = hasDart
          ? 'dart : ${supportNative ? 'native ' : ''}${supportWeb ? 'js' : ''}'
          : '';
      final String flutter = hasFlutter
          ? 'flutter : ${platforms.toString().replaceAll('[', '').replaceAll(']', '').replaceAll(',', ' ')}'
          : '';

      _description = TextSpan(children: <TextSpan>[
        const TextSpan(text: 'pub : '),
        TextSpan(
          text: '$pubApiBaseUrl/$name\n\n',
          style: const TextStyle(
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              launch('$pubApiBaseUrl/$name');
            },
        ),
        TextSpan(text: 'likes : ${score.likeCount}\n\n'),
        TextSpan(
            text: 'pub points : ${score.grantedPoints}/${score.maxPoints}\n\n'),
        TextSpan(
            text:
                'popularity : ${(score.popularityScore * 100 + 0.5).toInt()}%\n\n'),
        TextSpan(text: 'description : ${pubspec.description}\n\n'),
        TextSpan(text: 'version : ${pubspec.version}\n\n'),
        const TextSpan(text: 'homepage : '),
        TextSpan(
          text: '${pubspec.homepage}\n\n',
          style: const TextStyle(
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              launch(pubspec.homepage);
            },
        ),
        TextSpan(
            text: 'published : ${DateFormat("yyyy-MM-dd").format(time)}\n\n'),
        if (dart.isNotEmpty) TextSpan(text: '$dart\n\n'),
        if (flutter.isNotEmpty) TextSpan(text: '$flutter\n\n'),
        TextSpan(text: 'usage :  $name: ^${info.latest.version}\n\n'),
      ]);
    }

    return _description;
  }
}

class Category {
  Category(this.type, List<String> articles) {
    if (articles != null) {
      articles.sort(
        (String a, String b) => getSortNumber(a).compareTo(
          getSortNumber(b),
        ),
      );
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
    for (final MapEntry<String, List<String>> entry in candyConsts.entries) {
      final String root = entry.value.firstWhere(
          (String element) => basenameWithoutExtension(element) == entry.key);
      final String candies = entry.value.firstWhere(
          (String element) => basenameWithoutExtension(element) == 'candies');

      final CandyChef candyChef = CandyChef(
        entry.key,
        root,
        Candies(candies),
      );

      final Map<String, List<String>> group = groupBy<String, String>(
          entry.value
              .where((String element) => element != root && element != candies),
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

int getSortNumber(String path) {
  final List<String> list = basename(path).split('.');
  return int.tryParse(list.first) ?? 0;
}
