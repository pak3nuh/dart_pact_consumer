import 'package:json_annotation/json_annotation.dart';

part 'provider_state.g.dart';

@JsonSerializable(includeIfNull: false)
class ProviderState {
  String name;
  Map<String, dynamic>? params;

  ProviderState({
    required this.name,
    this.params,
  });

  factory ProviderState.fromJson(Map<String, dynamic> json) =>
      _$ProviderStateFromJson(json);

  Map<String, dynamic> toJson() => _$ProviderStateToJson(this);
}
