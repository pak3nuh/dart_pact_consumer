import 'dart:io';

import 'package:dart_pact_consumer/dart_pact_consumer.dart';
import 'package:dart_pact_consumer/src/ffi/rust_mock_server.dart';
import 'package:dart_pact_consumer/src/functional.dart';
import 'package:dart_pact_consumer/src/pact_exceptions.dart';
import 'package:test/test.dart';

void main() async {
  final serverFactory = await MockServerFactory.create();
  final repository = PactRepository();

  group('Mock server tests', () {
    tearDownAll(() {
      serverFactory.close();
    });

    test('should fail with no interactions', () async {
      final builder = PactBuilder('consumer', 'provider');
      final tester = builder.addState((state) {
        state.state = 'Given empty pet list';
        state.addRequest((request) {
          request
            ..path = '/pets'
            ..description = 'Get pet list'
            ..setResponse((response) {
              response.body = Body.json(Json.array([]));
            });
        });
      });

      try {
        await tester.test(serverFactory, (server) async {});
      } catch (ex) {
        expect(ex, isA<PactMatchingException>());
      }
      expect(RequestTester.hasErrors, isTrue);
    });

    test('should pass when interacted', () async {
      final builder = PactBuilder('consumer', 'provider');
      final tester = builder.addState((state) {
        state.state = 'Given empty pet list';
        state.addRequest((request) {
          request
            ..path = '/pets'
            ..description = 'Get pet list'
            ..setResponse((response) {
              response.body = Body.json(Json.array([]));
            });
        });
      });

      await tester.test(serverFactory, (server) async {
        await server.invoke('/pets');
      });
    });

    test('should accept bodies as payload', () async {
      final builder = PactBuilder('consumer', 'provider');
      final tester = builder.addState((state) {
        state.state = 'Given empty pet list';
        state.addRequest((request) {
          request
            ..method = Method.POST
            ..headers = {'accept': 'application/json'}
            ..path = '/pets'
            ..description = 'Post a pet'
            ..body = Body.json(Json.object({'name': 'Bob'}))
            ..setResponse((response) {
              response
                ..status = Status.created
                ..body = Body.isNullOrAbsent();
            });
        });
      });

      await tester.test(serverFactory, (server) async {
        await server.invoke('/pets',
            method: 'POST', status: 201, body: '''{"name":"Bob"}''');
      });
    });
  });
}
