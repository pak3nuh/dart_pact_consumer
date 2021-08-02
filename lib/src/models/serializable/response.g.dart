// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Response _$ResponseFromJson(Map<String, dynamic> json) {
  return Response(
    status: json['status'] as int,
    headers: (json['headers'] as Map<String, dynamic>?)?.map(
      (k, e) => MapEntry(k, e as String),
    ),
    body: Body.fromJsonToBody(json['body']),
    matchingRules: MatchingRules.fromJsonToMatchingRules(json['matchingRules']),
  );
}

Map<String, dynamic> _$ResponseToJson(Response instance) {
  final val = <String, dynamic>{
    'status': instance.status,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('headers', instance.headers);
  writeNotNull('body', instance.body);
  writeNotNull('matchingRules', instance.matchingRules);
  return val;
}
