import 'dart:io';
import 'package:candies_generator/candy_chef_generator.dart';
import 'package:candies_generator/watcher.dart';

void main(List<String> arguments) {
  final Watcher watcher = Watcher(go(), () {
    go();
    print('watching your assets now !');
  });
  watcher.startWatch();
}

List<Directory> go() {
  return mdGo();
  // print('');
  // return assetsGo();
}
