import 'package:json_annotation/json_annotation.dart';

import 'contract_builder_api.dart';

part 'pact_contract_dto.g.dart';

// formal specification
// https://github.com/pact-foundation/pact-specification/tree/version-4

@JsonSerializable()
class Contract {
  Provider provider;
  Consumer consumer;
  List<Interaction> interactions = [];
  Metadata metadata = Metadata();

  Contract();

  factory Contract.fromJson(Map<String, dynamic> json) =>
      _$ContractFromJson(json);

  Map<String, dynamic> toJson() => _$ContractToJson(this);
}

@JsonSerializable()
class Metadata {
  Metadata();

  Map<String, String> pactSpecification = {'version': '4.0'};

  @JsonKey(name: 'pact-dart')
  Map<String, String> pactDart = {'version': '0.0.1'};

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

  @JsonKey(fromJson: _fromJsonToBody)
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

  @JsonKey(fromJson: _fromJsonToBody)
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

Body _fromJsonToBody(dynamic body) {
  if (body == null) {
    return Body.none();
  }

  if (body is String) {
    return Body.string(body);
  }

  if (body is Map<String, dynamic>) {
    return Body.json(Json.object(body));
  }

  if (body is Iterable<dynamic>) {
    return Body.json(Json.array(body));
  }
  throw AssertionError('Unknown body type ${body.runtimeType}');
}
