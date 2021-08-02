import 'package:json_annotation/json_annotation.dart';

import '../body.dart';
import '../matching_rules.dart';

part 'request.g.dart';

@JsonSerializable(includeIfNull: false)
class Request {
  String method;
  String? path;
  String? query;
  Map<String, String>? headers;

  @JsonKey(fromJson: Body.fromJsonToBody)
  Body? body;

  @JsonKey(fromJson: MatchingRules.fromJsonToMatchingRules)
  MatchingRules? matchingRules;

  Request({
    required this.method,
    this.path,
    this.body,
    this.headers,
    this.query,
    this.matchingRules,
  });

  factory Request.fromJson(Map<String, dynamic> json) =>
      _$RequestFromJson(json);

  Map<String, dynamic> toJson() => _$RequestToJson(this);
}
