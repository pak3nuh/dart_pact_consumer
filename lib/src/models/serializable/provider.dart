import 'package:json_annotation/json_annotation.dart';

part 'provider.g.dart';

@JsonSerializable()
class Provider {
  String name;

  Provider({required this.name});

  factory Provider.fromJson(Map<String, dynamic> json) =>
      _$ProviderFromJson(json);

  Map<String, dynamic> toJson() => _$ProviderToJson(this);
}
