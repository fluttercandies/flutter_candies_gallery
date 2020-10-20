import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:flutter_candies_gallery/common/candies_const.dart';
import 'package:flutter_candies_gallery/route/flutter_candies_gallery_routes.dart';
import 'package:flutter_candies_gallery/route/flutter_candies_gallery_route.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:collection/collection.dart';
import 'package:flutter_candies_gallery/route//flutter_candies_gallery_routes.dart'
    as example_routes;
import 'package:waterfall_flow/waterfall_flow.dart';

@FFRoute(
  name: 'fluttercandies://mainpage',
  routeName: 'MainPage',
)
class MainPage extends StatelessWidget {
  MainPage() {
    final List<String> routeNames = <String>[];
    routeNames.addAll(example_routes.routeNames);
    routeNames.remove(Routes.fluttercandiesMainpage);
    routeNames.remove(Routes.fluttercandiesDemogrouppage);
    routesGroup.addAll(groupBy<DemoRouteResult, String>(
        routeNames
            .map<RouteResult>((String name) => getRouteResult(name: name))
            .where((RouteResult element) => element.exts != null)
            .map<DemoRouteResult>((RouteResult e) => DemoRouteResult(e))
            .toList()
              ..sort((DemoRouteResult a, DemoRouteResult b) =>
                  b.group.compareTo(a.group)),
        (DemoRouteResult x) => x.group));
  }
  final Map<String, List<DemoRouteResult>> routesGroup =
      <String, List<DemoRouteResult>>{};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FlutterCandies'),
        actions: <Widget>[
          ButtonTheme(
            minWidth: 0.0,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: FlatButton(
              child: const Text(
                'Github',
                style: TextStyle(
                  decorationStyle: TextDecorationStyle.solid,
                  decoration: TextDecoration.underline,
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                launch(
                    'https://github.com/fluttercandies/flutter_candies_gallery');
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ButtonTheme(
              padding: const EdgeInsets.only(right: 8.0),
              minWidth: 0.0,
              child: FlatButton(
                child: Image.network(
                    'https://pub.idqqimg.com/wpa/images/group.png'),
                onPressed: () {
                  launch('https://jq.qq.com/?_wv=1027&k=5bcc0gy');
                },
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Custom flutter candies(widgets) for you to build flutter app easily, enjoy it.',
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: WaterfallFlow.builder(
                gridDelegate:
                    const SliverWaterfallFlowDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 300,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemBuilder: (BuildContext c, int index) {
                  final CandyChef candyChef = CandyChiefs()[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed(
                          Routes.fluttercandiesCandyChefPage,
                          arguments: <String, dynamic>{
                            'candyChef': candyChef,
                          });
                    },
                    child: Card(
                      elevation: 8,
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Hero(
                                  tag: candyChef.name,
                                  child: ExtendedImage.asset(
                                    candyChef.avatar,
                                    shape: BoxShape.circle,
                                    width: 80,
                                    height: 80,
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
                          FutureBuilder<String>(
                            builder: (BuildContext c, AsyncSnapshot<String> d) {
                              if (!d.hasData) {
                                return Center(
                                  child: CircularProgressIndicator(
                                    backgroundColor: Colors.grey[200],
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                            Colors.blue),
                                  ),
                                );
                              }

                              return Markdown(
                                data: d.data,
                                shrinkWrap: true,
                                onTapLink: (String link) {
                                  launch(link);
                                },
                              );
                            },
                            future: candyChef.getIntroductionContent(),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                itemCount: CandyChiefs().length,
              ),
            ),
          )
        ],
      ),
    );
  }
}

@FFRoute(
  name: 'fluttercandies://demogrouppage',
  routeName: 'DemoGroupPage',
)
class DemoGroupPage extends StatelessWidget {
  DemoGroupPage({MapEntry<String, List<DemoRouteResult>> keyValue})
      : routes = keyValue.value
          ..sort((DemoRouteResult a, DemoRouteResult b) =>
              a.order.compareTo(b.order)),
        group = keyValue.key;
  final List<DemoRouteResult> routes;
  final String group;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$group demos'),
      ),
      body: ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          final DemoRouteResult page = routes[index];
          return Container(
            margin: const EdgeInsets.all(20.0),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    (index + 1).toString() + '.' + page.routeResult.routeName,
                    //style: TextStyle(inherit: false),
                  ),
                  Text(
                    page.routeResult.description,
                    style: const TextStyle(color: Colors.grey),
                  )
                ],
              ),
              onTap: () {
                Navigator.pushNamed(context, page.routeResult.name);
              },
            ),
          );
        },
        itemCount: routes.length,
      ),
    );
  }
}

class DemoRouteResult {
  DemoRouteResult(
    this.routeResult,
  )   : order = routeResult.exts['order'] as int,
        group = routeResult.exts['group'] as String;

  final int order;
  final String group;
  final RouteResult routeResult;
}
