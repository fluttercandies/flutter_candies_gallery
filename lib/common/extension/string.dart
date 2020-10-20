import 'package:flutter/services.dart';

extension StringE on String {
  Future<String> get assetString => rootBundle.loadString(this);
}
