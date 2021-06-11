import 'dart:convert';

import 'package:dart_pact_consumer/src/contract_builder_api.dart';
import 'package:dart_pact_consumer/src/pact_contract_dto.dart';
import 'package:test/test.dart';
import 'package:collection/collection.dart';

void main() {
  group('Pact contract DTO', () {
    test('should serialize to json', () {
      var contract = Pact(
        consumer: Consumer(name: 'my consumer'),
        provider: Provider(name: 'my Provider'),
        interactions: [
          Interaction(
            description: 'my description',
            providerStates: [ProviderState(name: 'my state')],
            request: Request(
              method: 'GET',
              path: 'my/path',
              query: {'name': 'john'},
              headers: {'accept': 'application/json'},
              body: Body.json(
                Json.array(
                  [
                    Json.object({'my-key': 'my-value'}),
                    'plain string'
                  ],
                ),
              ),
            ),
            response: Response(
              headers: {'content-type': 'text/plain'},
              status: 200,
              body: Body.isNullOrAbsent(),
            ),
          ),
        ],
      );

      var asJson = jsonDecode(jsonEncode(contract));

      const expected =
          '''{"provider":{"name":"my Provider"},"consumer":{"name":"my consumer"},"interactions":[{"description":"my description","request":{"method":"GET","path":"my/path","query":{"name":"john"},"headers":{"accept":"application/json"},"body":[{"my-key":"my-value"},"plain string"]},"response":{"status":200,"headers":{"content-type":"text/plain"},"body":null},"providerStates":[{"name":"my state","params":{}}]}],"metadata":{"pactSpecification":{"version":"3.0.0"},"pact-dart":{"version":"0.0.3"}}}''';
      final expectedJson = jsonDecode(expected);

      // [!] Matching Maps to ignore keys order
      expect(asJson, expectedJson);
    });
  });
}
