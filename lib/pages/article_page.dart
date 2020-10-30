import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_candies_gallery/model/candy.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_candies_gallery/common/extension/extension.dart';

@FFRoute(
  name: 'fluttercandies://ArticlePage',
  routeName: 'ArticlePage',
  argumentImports: <String>[
    'import \'package:flutter_candies_gallery/model/candy.dart\';'
  ],
)
class ArticlePage extends StatefulWidget {
  const ArticlePage(this.article);
  final Article article;
  @override
  _ArticlePageState createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  final TocController tocController = TocController();
  @override
  void dispose() {
    tocController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Article article = widget.article;
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

          final Widget markdown = Padding(
            padding: const EdgeInsets.all(8),
            child: Row(children: <Widget>[
              Expanded(
                flex: 4,
                child: MarkdownWidget(
                  data: d.data,
                  shrinkWrap: true,
                  controller: tocController,
                  styleConfig: StyleConfig(pConfig: PConfig(
                      //linkStyle: TextStyle(...),
                      onLinkTap: (String url) {
                    launch(url);
                  })),
                ),
              ),
              Expanded(
                flex: 1,
                child: TocListWidget(controller: tocController),
              ),
            ]),
          );
          if (context.isMobile) {
            return markdown;
          }
          final TargetPlatform platform = Theme.of(context).platform;

          return platform == TargetPlatform.macOS
              ? CupertinoScrollbar(
                  child: markdown,
                )
              : Scrollbar(
                  child: markdown,
                );
        },
        future: article.getContent(),
        initialData: article.content,
      ),
    );
  }
}
