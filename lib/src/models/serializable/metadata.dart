import 'package:json_annotation/json_annotation.dart';

part 'metadata.g.dart';

@JsonSerializable(includeIfNull: false)
class Metadata {
  final Map<String, String> pactSpecification;

  @JsonKey(name: 'pact-dart')
  final Map<String, String> pactDart;

  const Metadata({
    this.pactDart = const {'version': '1.2.0'},
    this.pactSpecification = const {'version': '3.0.0'},
  });

  factory Metadata.fromJson(Map<String, dynamic> json) =>
      _$MetadataFromJson(json);

  Map<String, dynamic> toJson() => _$MetadataToJson(this);
}