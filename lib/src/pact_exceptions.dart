
class PactException {
  final String message;

  PactException(this.message);

  @override
  String toString() {
    return '$runtimeType{message: $message}';
  }
}

class PactMatchingException extends PactException {
  final String _jsonMismatch;

  PactMatchingException(this._jsonMismatch) : super('Server has mismatches');

  @override
  String toString() {
    return 'PactMatchingException{message: $message, payload: $_jsonMismatch}';
  }
}
