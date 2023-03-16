import 'dart:ffi';
import 'package:ffi/ffi.dart';

import '../pact_exceptions.dart';

class PactFfiException extends PactException {
  PactFfiException(String message) : super(message);
}

_BooleanBridge _booleanBridge = _BooleanBridge();

// (buffer exploit or just memory garbage?)
/// Dart doesn't map every native type with FFI. Some of them need to be mapped
/// to primitives that are them fed to FFI methods.
///
/// Bools aren't mapped in FFI, instead they are treated like a number.
/// In the Dart SDK they use [Int8] to map booleans, but the conversion works
/// with larger FFI integers, although we need to mask the result.
///
/// See [NativeApi.closeNativePort]
class _BooleanBridge {
  bool fromNative(int input) {
    switch (input) {
      case 0:
        return false;
      case 1:
        return true;
      //sanity check
      default:
        throw AssertionError('Invalid boolean value $input');
    }
  }

  int toNative(bool input) => input ? 1 : 0;
}

extension _StringExt on String {
  Pointer<Utf8> toNative() {
    return this.toNativeUtf8();
  }
}

extension _Utf8PointerExt on Pointer<Utf8> {
  bool isNull() => this == nullptr;
}

/// Opens the shared library given a local path.
///
/// [envLogVariable] contains the name of the environment variable that
/// will tell the log level. Defaults to **PACT_MOCK_LOG_LEVEL**
/// Valid values for the log level are: TRACE; DEBUG; INFO; WARN; ERROR
///
/// [Docs](https://docs.rs/pact_mock_server_ffi/0.0.17/pact_mock_server_ffi/fn.init.html)
DynamicLibrary open(String libPath,
    {String envLogVariable = 'PACT_MOCK_LOG_LEVEL'}) {
  final lib = DynamicLibrary.open(libPath);
  _init(lib, envLogVariable);
  return lib;
}

typedef _initNative = Void Function(Pointer<Utf8> log_env_var);
typedef _initDart = void Function(Pointer<Utf8> log_env_var);

void _init(DynamicLibrary lib, String envLogVariable) {
  // todo functions can be cached for the same lib instance
  // see DynamicLibrary.open docs
  final initFunc = lib.lookupFunction<_initNative, _initDart>('init');
  initFunc(envLogVariable.toNative());
}

typedef _createMockServerNative = Int32 Function(
  Pointer<Utf8> pact_str,
  Pointer<Utf8> addr_str,
  Int8 /*bool*/ bool_tls,
);
typedef _createMockServerDart = int Function(
  Pointer<Utf8> pact_json_str,
  Pointer<Utf8> addr_str,
  int /*bool*/ bool_tls,
);

/// Creates a mock server for matching purposes.
///
/// [Docs](https://docs.rs/pact_mock_server_ffi/0.0.17/pact_mock_server_ffi/fn.create_mock_server.html)
int createMockServer(DynamicLibrary lib, String jsonPact,
    {String host = '127.0.0.1', int port = 0, bool useTls = false}) {
  assert(port >= 0, 'Invalid port');
  final createMockServerFunc =
      lib.lookupFunction<_createMockServerNative, _createMockServerDart>(
          'create_mock_server');
  final createResult = createMockServerFunc(
      jsonPact.toNative(),
      '$host:$port'.toNative(), // 0 leaves port handling to OS
      _booleanBridge.toNative(useTls));
  switch (createResult) {
    case -1:
      throw PactFfiException('A null pointer was received');
    case -2:
      throw PactFfiException('The pact JSON could not be parsed');
    case -3:
      throw PactFfiException('The mock server could not be started');
    case -4:
      throw PactFfiException('The method panicked');
    case -5:
      throw PactFfiException('The address is not valid');
    case -6:
      throw PactFfiException(
          'Could not create the TLS configuration with the self-signed certificate');
    default:
      assert(createResult > 0, 'Unknown result $createResult');
  }
  return createResult;
}

typedef _mockServerMatchedNative = Int8 /*bool*/ Function(
    Int32 mock_server_port);
typedef _mockServerMatchedDart = int /*bool*/ Function(int mock_server_port);

/// Returns a boolean indicating if the server on [port] as matched all requests.
///
/// [Docs](https://docs.rs/pact_mock_server_ffi/0.0.17/pact_mock_server_ffi/fn.mock_server_matched.html)
bool hasServerMatched(DynamicLibrary lib, int port) {
  final mockServerMatchedFunc =
      lib.lookupFunction<_mockServerMatchedNative, _mockServerMatchedDart>(
          'mock_server_matched');
  return _booleanBridge.fromNative(mockServerMatchedFunc(port));
}

typedef _mockServerMismatchNative = Pointer<Utf8> Function(
    Int32 mock_server_port);
typedef _mockServerMismatchDart = Pointer<Utf8> Function(int mock_server_port);

/// Returns a Json representation of all the mismatches that the server contains.
///
/// [Docs](https://docs.rs/pact_mock_server_ffi/0.0.17/pact_mock_server_ffi/fn.mock_server_mismatches.html)
String getJsonMismatch(DynamicLibrary lib, int port) {
  final mockServerMismatchFunc =
      lib.lookupFunction<_mockServerMismatchNative, _mockServerMismatchDart>(
          'mock_server_mismatches');
  final mismatchJsonPointer = mockServerMismatchFunc(port);
  if (mismatchJsonPointer.isNull()) {
    throw PactFfiException('Invalid server or function error');
  }
  return mismatchJsonPointer.toDartString();
}

typedef _cleanupMockServerNative = Int8 /*bool*/ Function(
    Int32 mock_server_port);
typedef _cleanupMockServerDart = int /*bool*/ Function(int mock_server_port);

/// Cleanups all resources for a previously created server. Returns true on
/// successful cleanup and false if something went wrong or the server doesn't exist.
///
/// [Docs](https://docs.rs/pact_mock_server_ffi/0.0.17/pact_mock_server_ffi/fn.cleanup_mock_server.html)
bool cleanup(DynamicLibrary lib, int port) {
  final cleanupMockServerFunc =
      lib.lookupFunction<_cleanupMockServerNative, _cleanupMockServerDart>(
          'cleanup_mock_server');
  return _booleanBridge.fromNative(cleanupMockServerFunc(port));
}

void writePactFile(DynamicLibrary lib, int port, {String? directory}) {
  final dirNative = directory == null ? nullptr : directory.toNative();
  var func = lib.lookupFunction<
      Int32 Function(Int32 port, Pointer<Utf8> directory),
      int Function(int port, Pointer<Utf8> directory)>('write_pact_file');

  var writeResult = func(port, dirNative);
  switch (writeResult) {
    case 0:
      break;
    case 1:
      throw PactFfiException('A general panic was caught');
    case 2:
      throw PactFfiException('The pact file was not able to be written');
    case 3:
      throw PactFfiException('A mock server with the provided port was not found');
    default:
      throw PactFfiException('Unknown result $writeResult');
  }
}

typedef _getCertificateNative = Pointer<Utf8> Function();
typedef _getCertificateDart = Pointer<Utf8> Function();

String getCertificate(DynamicLibrary lib) {
  var func = lib.lookupFunction<_getCertificateNative, _getCertificateDart>(
      'get_tls_ca_certificate');
  var result = func();
  if (result.isNull()) {
    throw PactFfiException('Invalid certificate from library');
  }

  return result.toDartString();
}
