import 'dart:convert' show json;
import 'package:flutter_candies_gallery/common/util.dart';

class PackageInfo {
  PackageInfo({
    this.latest,
    this.name,
    this.versions,
  });

  factory PackageInfo.fromJson(Map<String, dynamic> jsonRes) {
    if (jsonRes == null) {
      return null;
    }

    final List<Versions> versions =
        jsonRes['versions'] is List ? <Versions>[] : null;
    if (versions != null) {
      for (final dynamic item in jsonRes['versions']) {
        if (item != null) {
          tryCatch(() {
            versions.add(Versions.fromJson(asT<Map<String, dynamic>>(item)));
          });
        }
      }
    }
    return PackageInfo(
      latest: Latest.fromJson(asT<Map<String, dynamic>>(jsonRes['latest'])),
      name: asT<String>(jsonRes['name']),
      versions: versions,
    );
  }

  Latest latest;
  String name;
  List<Versions> versions;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'latest': latest,
        'name': name,
        'versions': versions,
      };
  @override
  String toString() {
    return json.encode(this);
  }
}

class Latest {
  Latest({
    this.archiveUrl,
    this.published,
    this.pubspec,
    this.version,
  });

  factory Latest.fromJson(Map<String, dynamic> jsonRes) => jsonRes == null
      ? null
      : Latest(
          archiveUrl: asT<String>(jsonRes['archive_url']),
          published: asT<String>(jsonRes['published']),
          pubspec:
              Pubspec.fromJson(asT<Map<String, dynamic>>(jsonRes['pubspec'])),
          version: asT<String>(jsonRes['version']),
        );

  String archiveUrl;
  String published;
  Pubspec pubspec;
  String version;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'archive_url': archiveUrl,
        'published': published,
        'pubspec': pubspec,
        'version': version,
      };
  @override
  String toString() {
    return json.encode(this);
  }
}

class Pubspec {
  Pubspec({
    this.description,
    this.environment,
    this.flutter,
    this.homepage,
    this.name,
    this.version,
  });

  factory Pubspec.fromJson(Map<String, dynamic> jsonRes) => jsonRes == null
      ? null
      : Pubspec(
          description: asT<String>(jsonRes['description']),
          environment: Environment.fromJson(
              asT<Map<String, dynamic>>(jsonRes['environment'])),
          flutter: asT<Object>(jsonRes['flutter']),
          homepage: asT<String>(jsonRes['homepage']),
          name: asT<String>(jsonRes['name']),
          version: asT<String>(jsonRes['version']),
        );

  String description;
  Environment environment;
  Object flutter;
  String homepage;
  String name;
  String version;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'description': description,
        'environment': environment,
        'flutter': flutter,
        'homepage': homepage,
        'name': name,
        'version': version,
      };
  @override
  String toString() {
    return json.encode(this);
  }
}

class Environment {
  Environment({
    this.flutter,
    this.sdk,
  });

  factory Environment.fromJson(Map<String, dynamic> jsonRes) => jsonRes == null
      ? null
      : Environment(
          flutter: asT<String>(jsonRes['flutter']),
          sdk: asT<String>(jsonRes['sdk']),
        );

  String flutter;
  String sdk;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'flutter': flutter,
        'sdk': sdk,
      };
  @override
  String toString() {
    return json.encode(this);
  }
}

class Flutter {
  Flutter({
    this.sdk,
  });

  factory Flutter.fromJson(Map<String, dynamic> jsonRes) => jsonRes == null
      ? null
      : Flutter(
          sdk: asT<String>(jsonRes['sdk']),
        );

  String sdk;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'sdk': sdk,
      };
  @override
  String toString() {
    return json.encode(this);
  }
}

class Versions {
  Versions({
    this.archiveUrl,
    this.published,
    this.pubspec,
    this.version,
  });

  factory Versions.fromJson(Map<String, dynamic> jsonRes) => jsonRes == null
      ? null
      : Versions(
          archiveUrl: asT<String>(jsonRes['archive_url']),
          published: asT<String>(jsonRes['published']),
          pubspec:
              Pubspec.fromJson(asT<Map<String, dynamic>>(jsonRes['pubspec'])),
          version: asT<String>(jsonRes['version']),
        );

  String archiveUrl;
  String published;
  Pubspec pubspec;
  String version;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'archive_url': archiveUrl,
        'published': published,
        'pubspec': pubspec,
        'version': version,
      };
  @override
  String toString() {
    return json.encode(this);
  }
}
