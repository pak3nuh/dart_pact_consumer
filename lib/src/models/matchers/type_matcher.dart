import '../json_serialize.dart';

class TypeMather implements CustomJson {
  @override
  Map<String, dynamic> toJson() {
    return {'matcher': 'type'};
  }
}