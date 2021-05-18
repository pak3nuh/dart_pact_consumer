// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pact_contract_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Pact _$PactFromJson(Map<String, dynamic> json) {
  return Pact()
    ..provider = json['provider'] == null
        ? null
        : Provider.fromJson(json['provider'] as Map<String, dynamic>)
    ..consumer = json['consumer'] == null
        ? null
        : Consumer.fromJson(json['consumer'] as Map<String, dynamic>)
    ..interactions = (json['interactions'] as List)
        ?.map((e) =>
            e == null ? null : Interaction.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..metadata = json['metadata'] == null
        ? null
        : Metadata.fromJson(json['metadata'] as Map<String, dynamic>);
}

Map<String, dynamic> _$PactToJson(Pact instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('provider', instance.provider);
  writeNotNull('consumer', instance.consumer);
  writeNotNull('interactions', instance.interactions);
  writeNotNull('metadata', instance.metadata);
  return val;
}

Metadata _$MetadataFromJson(Map<String, dynamic> json) {
  return Metadata()
    ..pactSpecification =
        (json['pactSpecification'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as String),
    )
    ..pactDart = (json['pact-dart'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as String),
    );
}

Map<String, dynamic> _$MetadataToJson(Metadata instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('pactSpecification', instance.pactSpecification);
  writeNotNull('pact-dart', instance.pactDart);
  return val;
}

Interaction _$InteractionFromJson(Map<String, dynamic> json) {
  return Interaction()
    ..type = json['type'] as String
    ..description = json['description'] as String
    ..request = json['request'] == null
        ? null
        : Request.fromJson(json['request'] as Map<String, dynamic>)
    ..response = json['response'] == null
        ? null
        : Response.fromJson(json['response'] as Map<String, dynamic>)
    ..providerStates = (json['providerStates'] as List)
        ?.map((e) => e == null
            ? null
            : ProviderState.fromJson(e as Map<String, dynamic>))
        ?.toList();
}

Map<String, dynamic> _$InteractionToJson(Interaction instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('type', instance.type);
  writeNotNull('description', instance.description);
  writeNotNull('request', instance.request);
  writeNotNull('response', instance.response);
  writeNotNull('providerStates', instance.providerStates);
  return val;
}

ProviderState _$ProviderStateFromJson(Map<String, dynamic> json) {
  return ProviderState()
    ..name = json['name'] as String
    ..params = json['params'] as Map<String, dynamic>;
}

Map<String, dynamic> _$ProviderStateToJson(ProviderState instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('name', instance.name);
  writeNotNull('params', instance.params);
  return val;
}

Response _$ResponseFromJson(Map<String, dynamic> json) {
  return Response()
    ..status = json['status'] as int
    ..headers = (json['headers'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as String),
    )
    ..body = _fromJsonToBody(json['body']);
}

Map<String, dynamic> _$ResponseToJson(Response instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('status', instance.status);
  writeNotNull('headers', instance.headers);
  writeNotNull('body', instance.body);
  return val;
}

Request _$RequestFromJson(Map<String, dynamic> json) {
  return Request()
    ..method = json['method'] as String
    ..path = json['path'] as String
    ..query = (json['query'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as String),
    )
    ..headers = (json['headers'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as String),
    )
    ..body = _fromJsonToBody(json['body']);
}

Map<String, dynamic> _$RequestToJson(Request instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('method', instance.method);
  writeNotNull('path', instance.path);
  writeNotNull('query', instance.query);
  writeNotNull('headers', instance.headers);
  writeNotNull('body', instance.body);
  return val;
}

Provider _$ProviderFromJson(Map<String, dynamic> json) {
  return Provider()..name = json['name'] as String;
}

Map<String, dynamic> _$ProviderToJson(Provider instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('name', instance.name);
  return val;
}

Consumer _$ConsumerFromJson(Map<String, dynamic> json) {
  return Consumer()..name = json['name'] as String;
}

Map<String, dynamic> _$ConsumerToJson(Consumer instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('name', instance.name);
  return val;
}
