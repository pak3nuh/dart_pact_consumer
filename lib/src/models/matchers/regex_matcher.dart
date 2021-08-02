import '../json_serialize.dart';

class RegexMatcher implements CustomJson {
  final String regex;

  RegexMatcher({required this.regex});

  @override
  Map<String, dynamic> toJson() {
    return {'matcher': 'regex', 'regex': regex};
  }
}
