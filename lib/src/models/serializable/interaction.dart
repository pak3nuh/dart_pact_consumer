import 'package:json_annotation/json_annotation.dart';

import 'request.dart';
import 'response.dart';
import 'provider_state.dart';

part 'interaction.g.dart';

@JsonSerializable(includeIfNull: false)
class Interaction {
  Request request;
  Response response;
  String? description;
  List<ProviderState>? providerStates;

  Interaction({
    required this.request,
    required this.response,
    this.description,
    this.providerStates = const [],
  });

  factory Interaction.fromJson(Map<String, dynamic> json) =>
      _$InteractionFromJson(json);

  Map<String, dynamic> toJson() => _$InteractionToJson(this);
}
