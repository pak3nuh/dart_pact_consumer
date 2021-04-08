
/// Marker function that complies with the Dart convention for Json
/// serialization.
/// This function is called by the serialization process.
/// See [_JsonStringifier.writeObject] and [_defaultToEncodable] functions
/// on the sky engine package.
///
/// Use this only on classes that shouldn't be annotated with [JsonSerializable]
abstract class CustomJson {
  dynamic toJson();
}