import 'package:dart_pact_consumer/dart_pact_consumer.dart';
import 'package:dart_pact_consumer/src/pact_exceptions.dart';
import 'package:test/test.dart';

void main() {
  group('Pact Repository tests', () {
    test('should require test with mock server by default', () {
      final builder = simpleBuilder();
      expect(() => PactRepository().add(builder), throwsPactException);
    });

    test('should get null on non existing pact', () {
      var pactFile = PactRepository().getPactFile('consumer', 'provider');
      expect(pactFile, isNull);
    });
    
    test('should get pact based on consumer and provider', () {
      var builder = simpleBuilder();
      var pactRepository = PactRepository(requireTests: false)
        ..add(builder);
      var pactFile = pactRepository.getPactFile('consumer', 'provider');
      expect(pactFile, isNotEmpty);
    });
  });
}

PactBuilder simpleBuilder() {
  return PactBuilder('consumer', 'provider')
      ..addState((stateBuilder) {
        stateBuilder
          ..state = 'my state'
          ..addRequest((reqBuilder) {
            reqBuilder.setResponse((respBuilder) {});
          });
      });
}

final throwsPactException = throwsA(isA<PactException>());
