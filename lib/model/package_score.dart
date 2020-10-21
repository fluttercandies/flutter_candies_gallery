import 'dart:convert' show json;
import 'package:flutter_candies_gallery/common/util.dart';

class PackageScore {
  PackageScore({
    this.grantedPoints,
    this.lastUpdated,
    this.likeCount,
    this.maxPoints,
    this.popularityScore,
  });

  factory PackageScore.fromJson(Map<String, dynamic> jsonRes) => jsonRes == null
      ? null
      : PackageScore(
          grantedPoints: asT<int>(jsonRes['grantedPoints']),
          lastUpdated: asT<String>(jsonRes['lastUpdated']),
          likeCount: asT<int>(jsonRes['likeCount']),
          maxPoints: asT<int>(jsonRes['maxPoints']),
          popularityScore: asT<double>(jsonRes['popularityScore']),
        );

  int grantedPoints;
  String lastUpdated;
  int likeCount;
  int maxPoints;
  double popularityScore;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'grantedPoints': grantedPoints,
        'lastUpdated': lastUpdated,
        'likeCount': likeCount,
        'maxPoints': maxPoints,
        'popularityScore': popularityScore,
      };
  @override
  String toString() {
    return json.encode(this);
  }
}
