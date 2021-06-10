import 'package:json_annotation/json_annotation.dart';

import 'contract_builder_api.dart';

part 'pact_contract_dto.g.dart';

// formal specification
// https://github.com/pact-foundation/pact-specification/tree/version-3

@JsonSerializable(includeIfNull: false)
class Pact {
  Provider provider;
  Consumer consumer;
  List<Interaction>? interactions;
  Metadata metadata = Metadata();

  Pact({
    required this.provider,
    required this.consumer,
    this.interactions,
    this.metadata = const Metadata(),
  });

  factory Pact.fromJson(Map<String, dynamic> json) => _$PactFromJson(json);

  Map<String, dynamic> toJson() => _$PactToJson(this);
}

@JsonSerializable(includeIfNull: false)
class Metadata {
  final Map<String, String> pactSpecification;

  @JsonKey(name: 'pact-dart')
  final Map<String, String> pactDart;

  const Metadata({
    this.pactDart = const {'version': '0.0.3'},
    this.pactSpecification = const {'version': '3.0.0'},
  });

  factory Metadata.fromJson(Map<String, dynamic> json) =>
      _$MetadataFromJson(json);

  Map<String, dynamic> toJson() => _$MetadataToJson(this);
}

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

@JsonSerializable(includeIfNull: false)
class Response {
  int status;

  Map<String, String>? headers;

  @JsonKey(fromJson: Body.fromJsonToBody)
  Body? body;

  Response({
    required this.status,
    this.headers,
    this.body,
  });

  factory Response.fromJson(Map<String, dynamic> json) =>
      _$ResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ResponseToJson(this);
}

@JsonSerializable(includeIfNull: false)
class Request {
  String method;
  String? path;
  Map<String, String>? query;
  Map<String, String>? headers;

  @JsonKey(fromJson: Body.fromJsonToBody)
  Body? body;

  Request({
    required this.method,
    this.path,
    this.body,
    this.headers,
    this.query,
  });

  factory Request.fromJson(Map<String, dynamic> json) =>
      _$RequestFromJson(json);

  Map<String, dynamic> toJson() => _$RequestToJson(this);
}

@JsonSerializable()
class Provider {
  String name;

  Provider({required this.name});

  factory Provider.fromJson(Map<String, dynamic> json) =>
      _$ProviderFromJson(json);

  Map<String, dynamic> toJson() => _$ProviderToJson(this);
}

@JsonSerializable()
class Consumer {
  String name;

  Consumer({required this.name});

  factory Consumer.fromJson(Map<String, dynamic> json) =>
      _$ConsumerFromJson(json);

  Map<String, dynamic> toJson() => _$ConsumerToJson(this);
}
