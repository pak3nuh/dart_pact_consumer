// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
