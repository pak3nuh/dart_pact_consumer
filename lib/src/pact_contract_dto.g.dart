// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pact_contract_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Pact _$PactFromJson(Map<String, dynamic> json) {
  return Pact(
    provider: Provider.fromJson(json['provider'] as Map<String, dynamic>),
    consumer: Consumer.fromJson(json['consumer'] as Map<String, dynamic>),
    interactions: (json['interactions'] as List<dynamic>?)
        ?.map((e) => Interaction.fromJson(e as Map<String, dynamic>))
        .toList(),
    metadata: Metadata.fromJson(json['metadata'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$PactToJson(Pact instance) {
  final val = <String, dynamic>{
    'provider': instance.provider,
    'consumer': instance.consumer,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('interactions', instance.interactions);
  val['metadata'] = instance.metadata;
  return val;
}

Metadata _$MetadataFromJson(Map<String, dynamic> json) {
  return Metadata(
    pactDart: Map<String, String>.from(json['pact-dart'] as Map),
    pactSpecification:
        Map<String, String>.from(json['pactSpecification'] as Map),
  );
}

Map<String, dynamic> _$MetadataToJson(Metadata instance) => <String, dynamic>{
      'pactSpecification': instance.pactSpecification,
      'pact-dart': instance.pactDart,
    };

Interaction _$InteractionFromJson(Map<String, dynamic> json) {
  return Interaction(
    request: Request.fromJson(json['request'] as Map<String, dynamic>),
    response: Response.fromJson(json['response'] as Map<String, dynamic>),
    description: json['description'] as String?,
    providerStates: (json['providerStates'] as List<dynamic>?)
        ?.map((e) => ProviderState.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$InteractionToJson(Interaction instance) {
  final val = <String, dynamic>{
    'request': instance.request,
    'response': instance.response,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('description', instance.description);
  writeNotNull('providerStates', instance.providerStates);
  return val;
}

ProviderState _$ProviderStateFromJson(Map<String, dynamic> json) {
  return ProviderState(
    name: json['name'] as String,
    params: json['params'] as Map<String, dynamic>?,
  );
}

Map<String, dynamic> _$ProviderStateToJson(ProviderState instance) {
  final val = <String, dynamic>{
    'name': instance.name,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('params', instance.params);
  return val;
}

Response _$ResponseFromJson(Map<String, dynamic> json) {
  return Response(
    status: json['status'] as int,
    headers: (json['headers'] as Map<String, dynamic>?)?.map(
      (k, e) => MapEntry(k, e as String),
    ),
    body: Body.fromJsonToBody(json['body']),
  );
}

Map<String, dynamic> _$ResponseToJson(Response instance) {
  final val = <String, dynamic>{
    'status': instance.status,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('headers', instance.headers);
  writeNotNull('body', instance.body);
  return val;
}

Request _$RequestFromJson(Map<String, dynamic> json) {
  return Request(
    method: json['method'] as String,
    path: json['path'] as String?,
    body: Body.fromJsonToBody(json['body']),
    headers: (json['headers'] as Map<String, dynamic>?)?.map(
      (k, e) => MapEntry(k, e as String),
    ),
    query: (json['query'] as Map<String, dynamic>?)?.map(
      (k, e) => MapEntry(k, e as String),
    ),
  );
}

Map<String, dynamic> _$RequestToJson(Request instance) {
  final val = <String, dynamic>{
    'method': instance.method,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('path', instance.path);
  writeNotNull('query', instance.query);
  writeNotNull('headers', instance.headers);
  writeNotNull('body', instance.body);
  return val;
}

Provider _$ProviderFromJson(Map<String, dynamic> json) {
  return Provider(
    name: json['name'] as String,
  );
}

Map<String, dynamic> _$ProviderToJson(Provider instance) => <String, dynamic>{
      'name': instance.name,
    };

Consumer _$ConsumerFromJson(Map<String, dynamic> json) {
  return Consumer(
    name: json['name'] as String,
  );
}

Map<String, dynamic> _$ConsumerToJson(Consumer instance) => <String, dynamic>{
      'name': instance.name,
    };
