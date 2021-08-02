import 'dart:convert';

import 'package:dart_pact_consumer/src/models/body.dart';
import 'package:dart_pact_consumer/src/models/json.dart';
import 'package:dart_pact_consumer/src/models/matchers/all.dart';
import 'package:dart_pact_consumer/src/models/matching_rules.dart';
import 'package:dart_pact_consumer/src/models/serializable/all.dart';
import 'package:test/test.dart';

void main() {
  group('Pact contract DTO', () {
    test('should serialize to json', () {
      var contract = Pact(
        consumer: Consumer(name: 'my Consumer'),
        provider: Provider(name: 'my Provider'),
        interactions: [
          Interaction(
            description: 'my description',
            providerStates: [ProviderState(name: 'my state')],
            request: Request(
              method: 'GET',
              path: 'my/path',
              query: 'name=john',
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
                matchingRules: MatchingRules.json(
                  Json.object({
                    'headers': Matchers(matchers: [
                      EqualityMatcher(),
                      DecimalMatcher(),
                      IntegerMatcher(),
                      MaxTypeMatcher(max: 10),
                      MinTypeMatcher(min: 2),
                      RegexMatcher(regex: '\d+'),
                      TypeMather(),
                    ]),
                  }),
                )),
          ),
        ],
      );

      var asJson = jsonDecode(jsonEncode(contract));

      const expected =
          '{"provider":{"name":"my Provider"},"consumer":{"name":"my Consumer"},"interactions":[{"request":{"method":"GET","path":"my/path","query":"name=john","headers":{"accept":"application/json"},"body":[{"my-key":"my-value"},"plain string"]},"response":{"status":200,"headers":{"content-type":"text/plain"},"body":null,"matchingRules":{"headers":{"matchers":[{"matcher":"equality"},{"matcher":"decimal"},{"matcher":"integer"},{"matcher":"type","max":10},{"matcher":"type","min":2},{"matcher":"regex","regex":"\d+"},{"matcher":"type"}]}}},"description":"my description","providerStates":[{"name":"my state"}]}],"metadata":{"pactSpecification":{"version":"3.0.0"},"pact-dart":{"version":"1.2.1"}}}';

      final expectedJson = jsonDecode(expected);

      // [!] Matching Maps to ignore keys order
      expect(asJson, expectedJson);
    });
  });
}
