import 'functional.dart';
import 'json_serialize.dart';
import 'json.dart';

// https://github.com/pact-foundation/pact-specification/tree/version-3#matchers
/// Models a request/response body.
class MatchingRules extends Union2<Json, String> implements CustomJson {
  /// Rules must be a Json object
  MatchingRules.json(Json json) : super.t1(json);

  /// Default matching rules (==)
  MatchingRules.empty() : super.t2('');

  /// Body is explicitly null or is absent.
  ///
  /// [Doc](https://github.com/pact-foundation/pact-specification/tree/version-3#body-is-present-but-is-null)

  @override
  dynamic toJson() {
    return fold(
      (js) => js.toJson(),
      (unit) => unit,
    );
  }

  static MatchingRules fromJsonToMatchingRules(dynamic rules) {
    if (rules == null) {
      return MatchingRules.empty();
    }

    if (rules == '') {
      return MatchingRules.empty();
    }

    if (rules is Map<String, dynamic>) {
      return MatchingRules.json(Json.object(rules));
    }

    if (rules is Iterable<dynamic>) {
      return MatchingRules.json(Json.array(rules));
    }

    throw AssertionError('Unknown matching rules type ${rules.runtimeType}');
  }
}
