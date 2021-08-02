import '../json_serialize.dart';

class DecimalMatcher implements CustomJson {
  @override
  Map<String, dynamic> toJson() {
    return {'matcher': 'decimal'};
  }
}
