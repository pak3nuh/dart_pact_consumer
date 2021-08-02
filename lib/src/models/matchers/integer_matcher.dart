import '../json_serialize.dart';

class IntegerMatcher implements CustomJson {
  @override
  Map<String, dynamic> toJson() {
    return {'matcher': 'integer'};
  }
}
