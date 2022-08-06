import 'package:test/test.dart';
import 'package:dart_pact_consumer/src/functional.dart';

void main() {
  setUp(() {});

  tearDown(() {});

  group('Scope functions', () {
    test('should not map null inputs', () {
        final String? s = null;
        final result = s.let((value) => throw Exception());
        expect(result, isNull);
    });

    test('should map non null inputs', () {
        final String s = '1';
        final result = s.let((value) => int.parse(value));
        expect(result, 1);
    });
  });

  group('Lazy', (){
      test('should invoke producer only once', () {
          var flag = false;
          var lazy = Default.fromProducer(() {
              if (flag) {
                  throw 'problem';
              }
              flag = true;
              return 1;
          });

          expect(lazy.value, 1);
          expect(lazy.value, 1);
          expect(flag, isTrue);
      });
  });
}