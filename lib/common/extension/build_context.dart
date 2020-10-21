import 'package:flutter/material.dart';

extension BuildContextE on BuildContext {
  bool get isMobile {
    final TargetPlatform platform = Theme.of(this).platform;
    return platform == TargetPlatform.iOS || platform == TargetPlatform.android;
  }
}
