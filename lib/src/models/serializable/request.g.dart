// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Request _$RequestFromJson(Map<String, dynamic> json) {
  return Request(
    method: json['method'] as String,
    path: json['path'] as String?,
    body: Body.fromJsonToBody(json['body']),
    headers: (json['headers'] as Map<String, dynamic>?)?.map(
      (k, e) => MapEntry(k, e as String),
    ),
    query: json['query'] as String?,
    matchingRules: MatchingRules.fromJsonToMatchingRules(json['matchingRules']),
  );
}

Map<String, dynamic> _$RequestToJson(Request instance) {
  final val = <String, dynamic>{
    'method': instance.method,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('path', instance.path);
  writeNotNull('query', instance.query);
  writeNotNull('headers', instance.headers);
  writeNotNull('body', instance.body);
  writeNotNull('matchingRules', instance.matchingRules);
  return val;
}
