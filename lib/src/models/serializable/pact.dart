import 'package:dart_pact_consumer/src/models/serializable/consumer.dart';
import 'package:dart_pact_consumer/src/models/serializable/interaction.dart';
import 'package:dart_pact_consumer/src/models/serializable/metadata.dart';
import 'package:dart_pact_consumer/src/models/serializable/provider.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pact.g.dart';

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