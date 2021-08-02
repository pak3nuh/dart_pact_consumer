import '../json_serialize.dart';

class MaxTypeMatcher implements CustomJson {
  final int max;

  MaxTypeMatcher({required this.max});

  @override
  Map<String, dynamic> toJson() {
    return {'matcher': 'type', 'max': max};
  }
}