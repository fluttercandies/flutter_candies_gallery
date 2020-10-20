import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_candies_gallery/common/candies_const.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

@FFRoute(
  name: 'fluttercandies://ArticlePage',
  routeName: 'ArticlePage',
  argumentImports: <String>[
    'import \'package:flutter_candies_gallery/common/candies_const.dart\';'
  ],
)
class ArticlePage extends StatelessWidget {
  const ArticlePage(this.article);
  final Article article;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          article.title,
        ),
      ),
      body: FutureBuilder<String>(
        builder: (BuildContext c, AsyncSnapshot<String> d) {
          if (!d.hasData) {
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            );
          }

          final Widget markdown = Markdown(
            data: d.data,
            onTapLink: (String link) {
              launch(link);
            },
          );
          final TargetPlatform platform = Theme.of(context).platform;
          if (platform == TargetPlatform.iOS ||
              platform == TargetPlatform.android) {
            return markdown;
          }

          return platform == TargetPlatform.macOS
              ? CupertinoScrollbar(
                  child: markdown,
                )
              : Scrollbar(
                  child: markdown,
                );
        },
        future: article.getContent(),
      ),
    );
  }
}
