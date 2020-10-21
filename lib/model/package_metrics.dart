import 'dart:convert' show json;
import 'package:flutter_candies_gallery/common/util.dart';
import 'package:flutter_candies_gallery/model/package_score.dart';

class PackageMetrics {
  PackageMetrics({
    this.score,
    this.scorecard,
  });

  factory PackageMetrics.fromJson(Map<String, dynamic> jsonRes) =>
      jsonRes == null
          ? null
          : PackageMetrics(
              score: PackageScore.fromJson(
                  asT<Map<String, dynamic>>(jsonRes['score'])),
              scorecard: Scorecard.fromJson(
                  asT<Map<String, dynamic>>(jsonRes['scorecard'])),
            );

  PackageScore score;
  Scorecard scorecard;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'score': score,
        'scorecard': scorecard,
      };
  @override
  String toString() {
    return json.encode(this);
  }
}

class Scorecard {
  Scorecard({
    this.packageName,
    this.packageVersion,
    this.runtimeVersion,
    this.updated,
    this.packageCreated,
    this.packageVersionCreated,
    this.grantedPubPoints,
    this.maxPubPoints,
    this.popularityScore,
    this.derivedTags,
    this.flags,
    this.reportTypes,
  });

  factory Scorecard.fromJson(Map<String, dynamic> jsonRes) {
    if (jsonRes == null) {
      return null;
    }

    final List<String> derivedTags =
        jsonRes['derivedTags'] is List ? <String>[] : null;
    if (derivedTags != null) {
      for (final dynamic item in jsonRes['derivedTags']) {
        if (item != null) {
          derivedTags.add(asT<String>(item));
        }
      }
    }

    final List<String> flags = jsonRes['flags'] is List ? <String>[] : null;
    if (flags != null) {
      for (final dynamic item in jsonRes['flags']) {
        if (item != null) {
          flags.add(asT<String>(item));
        }
      }
    }

    final List<String> reportTypes =
        jsonRes['reportTypes'] is List ? <String>[] : null;
    if (reportTypes != null) {
      for (final dynamic item in jsonRes['reportTypes']) {
        if (item != null) {
          reportTypes.add(asT<String>(item));
        }
      }
    }
    return Scorecard(
      packageName: asT<String>(jsonRes['packageName']),
      packageVersion: asT<String>(jsonRes['packageVersion']),
      runtimeVersion: asT<String>(jsonRes['runtimeVersion']),
      updated: asT<String>(jsonRes['updated']),
      packageCreated: asT<String>(jsonRes['packageCreated']),
      packageVersionCreated: asT<String>(jsonRes['packageVersionCreated']),
      grantedPubPoints: asT<int>(jsonRes['grantedPubPoints']),
      maxPubPoints: asT<int>(jsonRes['maxPubPoints']),
      popularityScore: asT<double>(jsonRes['popularityScore']),
      derivedTags: derivedTags,
      flags: flags,
      reportTypes: reportTypes,
    );
  }

  String packageName;
  String packageVersion;
  String runtimeVersion;
  String updated;
  String packageCreated;
  String packageVersionCreated;
  int grantedPubPoints;
  int maxPubPoints;
  double popularityScore;
  List<String> derivedTags;
  List<String> flags;
  List<String> reportTypes;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'packageName': packageName,
        'packageVersion': packageVersion,
        'runtimeVersion': runtimeVersion,
        'updated': updated,
        'packageCreated': packageCreated,
        'packageVersionCreated': packageVersionCreated,
        'grantedPubPoints': grantedPubPoints,
        'maxPubPoints': maxPubPoints,
        'popularityScore': popularityScore,
        'derivedTags': derivedTags,
        'flags': flags,
        'reportTypes': reportTypes,
      };
  @override
  String toString() {
    return json.encode(this);
  }
}
