import 'package:flutter/material.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';

@FFRoute(
  name: 'fluttercandies://demo2',
  routeName: 'demo2',
  description: 'demo2',
  exts: <String, dynamic>{
    'group': 'Complex',
    'order': 0,
  },
)
class Demo2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

