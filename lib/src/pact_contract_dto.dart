import 'package:json_annotation/json_annotation.dart';

import 'contract_builder_api.dart';

part 'pact_contract_dto.g.dart';

// formal specification
// https://github.com/pact-foundation/pact-specification/tree/version-3

@JsonSerializable()
class Pact {
  Provider provider;
  Consumer consumer;
  List<Interaction> interactions = [];
  Metadata metadata = Metadata();

  Pact();

  factory Pact.fromJson(Map<String, dynamic> json) =>
      _$PactFromJson(json);

  Map<String, dynamic> toJson() => _$PactToJson(this);
}

@JsonSerializable()
class Metadata {
  Metadata();

  Map<String, String> pactSpecification = {'version': '3.0.0'};

  @JsonKey(name: 'pact-dart')
  Map<String, String> pactDart = {'version': '0.0.3'};

  factory Metadata.fromJson(Map<String, dynamic> json) =>
      _$MetadataFromJson(json);

  Map<String, dynamic> toJson() => _$MetadataToJson(this);
}

@JsonSerializable()
class Interaction {
  String description;
  Request request;
  Response response;
  List<ProviderState> providerStates = [];

  Interaction();

  factory Interaction.fromJson(Map<String, dynamic> json) =>
      _$InteractionFromJson(json);

  Map<String, dynamic> toJson() => _$InteractionToJson(this);
}

@JsonSerializable()
class ProviderState {
  String name;
  Map<String, dynamic> params = {};

  ProviderState();

  factory ProviderState.fromJson(Map<String, dynamic> json) =>
      _$ProviderStateFromJson(json);

  Map<String, dynamic> toJson() => _$ProviderStateToJson(this);
}

@JsonSerializable()
class Response {
  int status;

  Response();

  Map<String, String> headers = {};

  @JsonKey(fromJson: Body.fromJsonToBody)
  Body body;

  factory Response.fromJson(Map<String, dynamic> json) =>
      _$ResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ResponseToJson(this);
}

@JsonSerializable()
class Request {
  Request();

  String method;
  String path;
  Map<String, String> query = {};
  Map<String, String> headers = {};

  @JsonKey(fromJson: Body.fromJsonToBody)
  Body body;

  factory Request.fromJson(Map<String, dynamic> json) =>
      _$RequestFromJson(json);

  Map<String, dynamic> toJson() => _$RequestToJson(this);
}

@JsonSerializable()
class Provider {
  String name;

  Provider();

  factory Provider.fromJson(Map<String, dynamic> json) =>
      _$ProviderFromJson(json);

  Map<String, dynamic> toJson() => _$ProviderToJson(this);
}

@JsonSerializable()
class Consumer {
  String name;

  Consumer();

  factory Consumer.fromJson(Map<String, dynamic> json) =>
      _$ConsumerFromJson(json);

  Map<String, dynamic> toJson() => _$ConsumerToJson(this);
}
