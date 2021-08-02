// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
