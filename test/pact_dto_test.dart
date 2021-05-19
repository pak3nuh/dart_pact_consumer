import 'dart:convert';

import 'package:dart_pact_consumer/src/contract_builder_api.dart';
import 'package:dart_pact_consumer/src/pact_contract_dto.dart';
import 'package:test/test.dart';

void main() {

  group('Pact contract DTO', () {
    test('should serialize to json', () {
      var contract = Pact();
      contract
        ..consumer = (Consumer()..name = 'my consumer')
        ..provider = (Provider()..name = 'my Provider')
        ..interactions = [
          Interaction()
            ..description = 'my description'
            ..providerStates = [ProviderState()..name = 'my state']
            ..type = 'Synchronous/HTTP'
            ..request = (Request()
              ..method = 'GET'
              ..path = 'my/path'
              ..query = {'name': 'john'}
              ..headers = {'accept': 'application/json'}
              ..body = (RequestResponseBody()..content = {"my-key": "my-value"}))
            ..response = (Response()
              ..headers = {"content-type": "text/plain"}
              ..status = 200
              ..body = null)
        ];

      var asJson = contract.toJson();
      var asString = jsonEncode(asJson);
      //prints(asJson);
      const expected =
      '''{"provider":{"name":"my Provider"},"consumer":{"name":"my consumer"},"interactions":[{"type":"Synchronous/HTTP","description":"my description","request":{"method":"GET","path":"my/path","query":{"name":"john"},"headers":{"accept":"application/json"},"body":{"content":{"my-key":"my-value"}}},"response":{"status":200,"headers":{"content-type":"text/plain"}},"providerStates":[{"name":"my state","params":{}}]}],"metadata":{"pactSpecification":{"version":"4.0"},"pact-dart":{"version":"0.0.1"}}}''';
      expect(asString, expected);
    });
  });
}