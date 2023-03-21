// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pact_contract_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Pact _$PactFromJson(Map<String, dynamic> json) => Pact()
  ..provider = Provider.fromJson(json['provider'] as Map<String, dynamic>)
  ..consumer = Consumer.fromJson(json['consumer'] as Map<String, dynamic>)
  ..interactions = (json['interactions'] as List<dynamic>)
      .map((e) => Interaction.fromJson(e as Map<String, dynamic>))
      .toList()
  ..metadata = Metadata.fromJson(json['metadata'] as Map<String, dynamic>);

Map<String, dynamic> _$PactToJson(Pact instance) => <String, dynamic>{
      'provider': instance.provider,
      'consumer': instance.consumer,
      'interactions': instance.interactions,
      'metadata': instance.metadata,
    };

Metadata _$MetadataFromJson(Map<String, dynamic> json) => Metadata()
  ..pactSpecification =
      Map<String, String>.from(json['pactSpecification'] as Map)
  ..pactDart = Map<String, String>.from(json['pact-dart'] as Map);

Map<String, dynamic> _$MetadataToJson(Metadata instance) => <String, dynamic>{
      'pactSpecification': instance.pactSpecification,
      'pact-dart': instance.pactDart,
    };

Interaction _$InteractionFromJson(Map<String, dynamic> json) => Interaction()
  ..description = json['description'] as String
  ..request = Request.fromJson(json['request'] as Map<String, dynamic>)
  ..response = Response.fromJson(json['response'] as Map<String, dynamic>)
  ..providerStates = (json['providerStates'] as List<dynamic>)
      .map((e) => ProviderState.fromJson(e as Map<String, dynamic>))
      .toList();

Map<String, dynamic> _$InteractionToJson(Interaction instance) =>
    <String, dynamic>{
      'description': instance.description,
      'request': instance.request,
      'response': instance.response,
      'providerStates': instance.providerStates,
    };

ProviderState _$ProviderStateFromJson(Map<String, dynamic> json) =>
    ProviderState()
      ..name = json['name'] as String
      ..params = json['params'] as Map<String, dynamic>;

Map<String, dynamic> _$ProviderStateToJson(ProviderState instance) =>
    <String, dynamic>{
      'name': instance.name,
      'params': instance.params,
    };

Response _$ResponseFromJson(Map<String, dynamic> json) => Response()
  ..status = json['status'] as int
  ..headers = Map<String, String>.from(json['headers'] as Map)
  ..body = Body.fromJsonToBody(json['body']);

Map<String, dynamic> _$ResponseToJson(Response instance) => <String, dynamic>{
      'status': instance.status,
      'headers': instance.headers,
      'body': instance.body,
    };

Request _$RequestFromJson(Map<String, dynamic> json) => Request()
  ..method = json['method'] as String
  ..path = json['path'] as String
  ..query = Map<String, String>.from(json['query'] as Map)
  ..headers = Map<String, String>.from(json['headers'] as Map)
  ..body = Body.fromJsonToBody(json['body']);

Map<String, dynamic> _$RequestToJson(Request instance) => <String, dynamic>{
      'method': instance.method,
      'path': instance.path,
      'query': instance.query,
      'headers': instance.headers,
      'body': instance.body,
    };

Provider _$ProviderFromJson(Map<String, dynamic> json) =>
    Provider()..name = json['name'] as String;

Map<String, dynamic> _$ProviderToJson(Provider instance) => <String, dynamic>{
      'name': instance.name,
    };

Consumer _$ConsumerFromJson(Map<String, dynamic> json) =>
    Consumer()..name = json['name'] as String;

Map<String, dynamic> _$ConsumerToJson(Consumer instance) => <String, dynamic>{
      'name': instance.name,
    };
