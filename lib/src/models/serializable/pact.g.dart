// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pact.dart';

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
