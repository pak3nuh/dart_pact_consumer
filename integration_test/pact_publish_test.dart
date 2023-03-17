import 'dart:convert';
import 'dart:io';

import 'package:dart_pact_consumer/dart_pact_ffi.dart';
import 'package:dart_pact_consumer/src/contract_builder_api.dart';
import 'package:dart_pact_consumer/src/pact_host_client.dart';
import 'package:test/test.dart';

void main() async {
  const brokerUrl = 'http://192.168.96.1:9292';
  final serverFactory = await MockServerFactory.create();

  group('ContractBuilder for pact broker', () {
    final host = PactHost(brokerUrl);
    final repo = PactRepository();

    PactBuilder petShopApiBuilder() {
      return PactBuilder('dart-consumer', 'pet-shop-api-provider');
    }

    test('should get pet list', () async {
      final builder = petShopApiBuilder();
      final tester = builder.addState((st) => st
        ..state = 'pet shop with 3 pets'
        ..addRequest((req) => req
          ..description = 'should get pet list'
          ..method = Method.GET
          ..path = '/pets'
          ..setResponse((resp) => resp
            ..status = Status(200)
            ..body = Body.json(Json.array([
              Json.object({'id': 1, 'name': 'Baby shark', 'kind': 'Shark'}),
              Json.object({'id': 2, 'name': 'Mr whiskers', 'kind': 'Cat'}),
              Json.object({'id': 3, 'name': 'Bob', 'kind': 'Dog'})
            ])))));

      await tester.test(serverFactory, (server) async {
        final response = await server.invoke('/pets');
        final jsonDecoded = await response.decodeAsJson();
        expect(jsonDecoded, isA<Iterable<dynamic>>());
        expect(jsonDecoded.length, 3);
      });

      repo.add(builder);
    });

    test('should get pet filtered', () async {
      final builder = petShopApiBuilder();
      final tester = builder.addState((st) => st
          ..state = 'pet shop with 3 pets'
          ..addRequest((req) => req
            ..description = 'should get only Bob'
            ..method = Method.GET
            ..path = '/pets'
            ..query = {'name': 'Bob'}
            ..setResponse((resp) => resp
              ..status = Status(200)
              ..body = Body.json(Json.array([
                Json.object({'id': 3, 'name': 'Bob', 'kind': 'Dog'})
              ])))));

      await tester.test(serverFactory, (server) async {
        final response = await server.invoke('/pets?name=Bob');
        final jsonDecoded = await response.decodeAsJson();
        expect(jsonDecoded, isA<Iterable<dynamic>>());
        expect(jsonDecoded.length, 1);
        expect(jsonDecoded[0]['name'], 'Bob');
      });

      repo.add(builder);
    });

    tearDownAll(() async {
      final closed = serverFactory.close();
      expect(closed, isTrue);
      await repo.publish(host, '0.0.1');
    });
  });

}

extension JsonResponse on HttpClientResponse {
  Future<dynamic> decodeAsJson() async {
    final folded = await fold<List<int>>(
        [], (previous, element) => previous..addAll(element));
    final stringDecoded = utf8.decode(folded);
    return jsonDecode(stringDecoded);
  }
}
