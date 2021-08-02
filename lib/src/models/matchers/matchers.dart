import '../json_serialize.dart';

class Matchers implements CustomJson {
  final List<CustomJson> matchers;

  Matchers({required this.matchers});

  @override
  Map<String, List<dynamic>> toJson() {
    return {
      'matchers': matchers.map((e) => e.toJson()).toList(),
    };
  }
}
