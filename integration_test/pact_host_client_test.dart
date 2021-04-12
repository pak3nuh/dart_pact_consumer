import 'package:dart_pact_consumer/dart_pact_consumer.dart';
import 'package:dart_pact_consumer/src/pact_host_client.dart';
import 'package:test/test.dart';

void main() {
  group('PactHost', () {
    const host = 'http://localhost:9292';
    final client = PactHost(host);

    test('should get contracts', () async {
      await client.addTag(
          'dart-consumer', '0.0.1', 'my-special-tag');

      await client.addTag(
          'pet-shop-api-provider', '0.0.1', 'my-special-tag');

      await client.addLabel('pet-shop-api-provider', 'my-label');
    });
  });
}
