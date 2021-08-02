import 'functional.dart';
import 'json_serialize.dart';
import 'json.dart';

// https://github.com/pact-foundation/pact-specification/tree/version-3#semantics-around-body-values
/// Models a request/response body.
class Body extends Union3<Json, String, Unit> implements CustomJson {
  /// Body must be a Json object
  Body.json(Json json) : super.t1(json);

  /// Body must be a string
  Body.string(String str)
      : assert(str.isNotEmpty),
        super.t2(str);

  /// Body must be empty
  Body.empty() : super.t2('');

  /// Body is explicitly null or is absent.
  ///
  /// [Doc](https://github.com/pact-foundation/pact-specification/tree/version-3#body-is-present-but-is-null)
  Body.isNullOrAbsent() : super.t3(unit);

  @override
  dynamic toJson() {
    return fold(
          (js) => js.toJson(),
          (str) => str,
          (unit) => unit.toJson(),
    );
  }

  static Body fromJsonToBody(dynamic body) {
    if (body == null) {
      return Body.isNullOrAbsent();
    }

    if (body == '') {
      return Body.empty();
    }

    if (body is String) {
      return Body.string(body);
    }

    if (body is Map<String, dynamic>) {
      return Body.json(Json.object(body));
    }

    if (body is Iterable<dynamic>) {
      return Body.json(Json.array(body));
    }
    throw AssertionError('Unknown body type ${body.runtimeType}');
  }
}