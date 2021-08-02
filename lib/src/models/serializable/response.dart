import 'package:json_annotation/json_annotation.dart';

import '../body.dart';
import '../matching_rules.dart';

part 'response.g.dart';

@JsonSerializable(includeIfNull: false)
class Response {
  int status;

  Map<String, String>? headers;

  @JsonKey(fromJson: Body.fromJsonToBody)
  Body? body;

  @JsonKey(fromJson: MatchingRules.fromJsonToMatchingRules)
  MatchingRules? matchingRules;

  Response({
    required this.status,
    this.headers,
    this.body,
    this.matchingRules,
  });

  factory Response.fromJson(Map<String, dynamic> json) =>
      _$ResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ResponseToJson(this);
}
