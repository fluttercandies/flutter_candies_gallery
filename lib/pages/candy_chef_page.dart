import 'package:extended_image/extended_image.dart';
import 'package:extended_sliver/extended_sliver.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:flutter_candies_gallery/common/candies_const.dart';
import 'package:flutter_candies_gallery/route/flutter_candies_gallery_routes.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

@FFRoute(
  name: 'fluttercandies://CandyChefPage',
  routeName: 'CandyChefPage',
  argumentImports: <String>[
    'import \'package:flutter_candies_gallery/common/candies_const.dart\';'
  ],
)
class CandyChefPage extends StatefulWidget {
  const CandyChefPage(this.candyChef);
  final CandyChef candyChef;
  @override
  _CandyChefPageState createState() => _CandyChefPageState();
}

class _CandyChefPageState extends State<CandyChefPage> {
  @override
  Widget build(BuildContext context) {
    final CandyChef candyChef = widget.candyChef;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Hero(
                tag: candyChef.name,
                child: ExtendedImage.asset(
                  candyChef.avatar,
                  shape: BoxShape.circle,
                  width: 40,
                  height: 40,
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.5),
                    width: 1,
                  ),
                ),
              ),
            ),
            Text(candyChef.name),
          ],
        ),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          FutureBuilder<String>(
            builder: (BuildContext c, AsyncSnapshot<String> d) {
              if (!d.hasData) {
                return SliverPinnedToBoxAdapter(
                  child: Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.grey[200],
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                );
              }

              return SliverPinnedToBoxAdapter(
                child: Material(
                  child: Markdown(
                    data: d.data,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    onTapLink: (String link) {
                      launch(link);
                    },
                  ),
                ),
              );
            },
            future: candyChef.getIntroductionContent(),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(8.0),
            sliver: SliverWaterfallFlow(
              gridDelegate:
                  const SliverWaterfallFlowDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  final Category category = candyChef.categories[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(category.type),
                          ...category.articles.map<Widget>((Article article) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text.rich(
                                TextSpan(
                                  text:
                                      '${category.articles.indexOf(article) + 1}. ${article.title}',
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.of(context).pushNamed(
                                          Routes.fluttercandiesArticlePage,
                                          arguments: <String, dynamic>{
                                            'article': article,
                                          });
                                    },
                                ),
                                style: const TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Colors.blue,
                                ),
                              ),
                            );
                          })
                        ],
                      ),
                    ),
                  );
                },
                childCount: candyChef.categories.length,
              ),
            ),
          )
        ],
      ),
    );
  }
}
