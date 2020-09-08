import 'package:flutter/material.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';

@FFRoute(
  name: 'fluttercandies://demo1',
  routeName: 'demo1',
  description: 'demo1',
  exts: <String, dynamic>{
    'group': 'Simple',
    'order': 0,
  },
)
class Demo1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

