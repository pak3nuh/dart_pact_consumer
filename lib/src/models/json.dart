import 'functional.dart';
import 'json_serialize.dart';

/// Models a Json object.
///
/// The definition is relaxed to dynamic to allow more flexibility. No need
/// to create unions for every valid Json type.
///
/// Designed to work with custom Json objects or to interoperate with
/// classes that comply with the Json serialization conventions.
class Json extends Union2<Iterable<dynamic>, Map<String, dynamic>>
    implements CustomJson {
  Json.object(Map<String, dynamic> json) : super.t2(json);

  Json.array(Iterable<dynamic> json) : super.t1(json);

  @override
  dynamic toJson() {
    return fold(
          (arr) => arr,
          (obj) => obj,
    );
  }
}
