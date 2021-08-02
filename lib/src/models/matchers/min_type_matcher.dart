import '../json_serialize.dart';

class MinTypeMatcher implements CustomJson {
  final int min;

  MinTypeMatcher({required this.min});

  @override
  Map<String, dynamic> toJson() {
    return {'matcher': 'type', 'min': min};
  }
}