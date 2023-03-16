
/// Marker function that complies with the Dart convention for Json
/// serialization.
/// This function is called by the serialization process if it is not one
/// of the built in serializable types.
/// See [_JsonStringifier.writeObject] and [_defaultToEncodable] functions
/// on the sky engine package.
///
/// Use this only on classes that shouldn't be annotated with [JsonSerializable]
abstract class CustomJson {
  /// To be called for a custom json serialization.
  /// This is not a chainable call. If the result is writeable by the
  /// stringifier, it will result in an exception.
  dynamic toJson();
}

/// Same as [CustomJson] but reified.
/// Use with [JsonSerializable] annotated classes
abstract class ReifiedJson {
  Map<String, dynamic> toJson();
}