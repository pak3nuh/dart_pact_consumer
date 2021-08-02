import 'package:json_annotation/json_annotation.dart';

part 'consumer.g.dart';

@JsonSerializable()
class Consumer {
  String name;

  Consumer({required this.name});

  factory Consumer.fromJson(Map<String, dynamic> json) =>
      _$ConsumerFromJson(json);

  Map<String, dynamic> toJson() => _$ConsumerToJson(this);
}
