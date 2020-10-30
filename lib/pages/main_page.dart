import 'package:flutter/material.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';

import 'package:flutter_candies_gallery/pages/home_page.dart';
import 'package:flutter_candies_gallery/route/flutter_candies_gallery_routes.dart';
import 'package:flutter_candies_gallery/route/flutter_candies_gallery_route.dart';

import 'package:collection/collection.dart';
import 'package:flutter_candies_gallery/route//flutter_candies_gallery_routes.dart'
    as example_routes;
import 'home_page.dart';

@FFRoute(
  name: 'fluttercandies://mainpage',
  routeName: 'MainPage',
)
class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  TabController controller;
  @override
  void initState() {
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
    controller = TabController(
      length: 5,
      vsync: this,
    );
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  final Map<String, List<DemoRouteResult>> routesGroup =
      <String, List<DemoRouteResult>>{};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('FlutterCandies'),
      //   actions: <Widget>[
      //     ButtonTheme(
      //       minWidth: 0.0,
      //       padding: const EdgeInsets.symmetric(horizontal: 8.0),
      //       child: FlatButton(
      //         child: const Text(
      //           'Github',
      //           style: TextStyle(
      //             decorationStyle: TextDecorationStyle.solid,
      //             decoration: TextDecoration.underline,
      //             color: Colors.white,
      //           ),
      //         ),
      //         onPressed: () {
      //           launch(
      //               'https://github.com/fluttercandies/flutter_candies_gallery');
      //         },
      //       ),
      //     ),
      //     Padding(
      //       padding: const EdgeInsets.symmetric(horizontal: 8.0),
      //       child: ButtonTheme(
      //         padding: const EdgeInsets.only(right: 8.0),
      //         minWidth: 0.0,
      //         child: FlatButton(
      //           child: Image.network(
      //               'https://pub.idqqimg.com/wpa/images/group.png'),
      //           onPressed: () {
      //             launch('https://jq.qq.com/?_wv=1027&k=5bcc0gy');
      //           },
      //         ),
      //       ),
      //     )
      //   ],
      // ),
      body: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  'assets/images/avatars/flutter_candies_logo.png',
                  width: 60,
                  height: 60,
                ),
              ),
            ],
          ),
          TabBar(
            controller: controller,
            tabs: const <Widget>[
              Tab(
                text: 'Home',
              ),
              Tab(
                text: 'Candy',
              ),
              Tab(
                text: 'Github',
              ),
              Tab(
                text: 'Blog',
              ),
              Tab(
                text: 'About',
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: controller,
              children: <Widget>[
                HomePage(),
                Container(child: const Text('Candy')),
                Container(child: const Text('Github')),
                Container(child: const Text('Blog')),
                Container(child: const Text('About')),
              ],
            ),
          ),
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
