import 'dart:convert' as json;
import 'package:flutter_candies_gallery/common/util.dart';
import 'package:flutter_candies_gallery/model/package_info.dart';
import 'package:flutter_candies_gallery/model/package_metrics.dart';
import 'package:flutter_candies_gallery/model/package_score.dart';
import 'package:http/http.dart' as http;

String get pubApiBaseUrl =>
    isCN ? 'https://pub.flutter-io.cn' : 'https://pub.dev';

class PubApi {
  factory PubApi() => _pubApi;
  PubApi._();
  static final PubApi _pubApi = PubApi._();

  Future<PackageInfo> getInfo(String name) async {
    final http.Response response =
        await http.get('$pubApiBaseUrl/api/packages/$name');

    return PackageInfo.fromJson(
        json.jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<PackageScore> getScore(String name) async {
    final http.Response response =
        await http.get('$pubApiBaseUrl/api/packages/$name/score');

    return PackageScore.fromJson(
        json.jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<PackageMetrics> getSMetrics(String name) async {
    final http.Response response =
        await http.get('$pubApiBaseUrl/api/packages/$name/metrics');

    return PackageMetrics.fromJson(
        json.jsonDecode(response.body) as Map<String, dynamic>);
  }
}
