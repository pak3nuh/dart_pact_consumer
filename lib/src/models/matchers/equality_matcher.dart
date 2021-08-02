import '../json_serialize.dart';

class EqualityMatcher implements CustomJson {
  @override
  Map<String, dynamic> toJson() {
    return {'matcher': 'equality'};
  }
}
