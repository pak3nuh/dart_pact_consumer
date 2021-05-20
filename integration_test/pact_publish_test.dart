import 'package:dart_pact_consumer/src/contract_builder_api.dart';
import 'package:dart_pact_consumer/src/pact_host_client.dart';
import 'package:test/test.dart';

void main() {
  const brokerUrl = 'http://localhost:9292';

  group('ContractBuilder for pact broker', () {
    final host = PactHost(brokerUrl);
    final repo = PactRepository();

    PactBuilder petShopApiBuilder() {
      return PactBuilder()
        ..consumer = 'dart-consumer'
        ..provider = 'pet-shop-api-provider';
    }

    test('should get pet list', () async {
      final builder = petShopApiBuilder()
        ..addState((st) => st
          ..state = 'pet shop with 3 pets'
          ..addRequest((req) => req
            ..description = 'should get pet list'
            ..type = InteractionType.SYNCHRONOUS_HTTP
            ..method = Method.GET
            ..path = '/pets/'
            ..setResponse((resp) => resp
              ..status = Status(200)
              ..body = Body.json(Json.array([
                Json.object({
                  'id': 1,
                  'name': 'Baby shark',
                  'kind': 'Shark'
                }),
                Json.object({
                  'id': 2,
                  'name': 'Mr whiskers',
                  'kind': 'Cat'
                }),
                Json.object({
                  'id': 3,
                  'name': 'Bob',
                  'kind': 'Dog'
                })
              ])))));

      repo.add(builder);
    });

    test('should get pet filtered', () async {
      final builder = petShopApiBuilder()
        ..addState((st) => st
          ..state = 'pet shop with 3 pets'
          ..addRequest((req) => req
            ..description = 'should get only Bob'
            ..method = Method.GET
            ..path = '/pets/'
            ..query = {
              'name': 'Bob'
            }
            ..setResponse((resp) => resp
              ..status = Status(200)
              ..body = Body.json(Json.array([
                Json.object({
                  'id': 3,
                  'name': 'Bob',
                  'kind': 'Dog'
                })
              ])))));

      repo.add(builder);
    });

    tearDownAll(() async {
      await repo.publish(host, '0.0.1');
    });
  });
}