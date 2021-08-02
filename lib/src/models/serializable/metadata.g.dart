// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metadata.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
