import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:dart_pact_consumer/dart_pact_consumer.dart';

import '../pact_exceptions.dart';
import '../functional.dart';
import 'rust_library_bindings.dart' as bindings;

final _default_lib_path =
    Directory.systemTemp.path + '/libpact_mock_server_ffi-v0.0.17';

/// Factory that uses the [rust ffi v0.0.17](https://docs.rs/pact_mock_server_ffi/0.0.17)
/// bindings to create a mock server to execute the matching process.
class MockServerFactory {
  final DynamicLibrary _ffiLib;

  final Map<int, MockServer> _servers = {};

  MockServerFactory._(this._ffiLib);

  /// Starts a mock server for a single interaction.
  ///
  /// The mock server was intended to use on a single test lifecycle
  /// (interaction). Due to limitations of the Dart FFI, building the contract
  /// on the external library is not possible.
  ///
  /// If [port] is null, then is assigned by the operating system
  MockServer createMockServer(Interaction interaction, {int? port}) {
    final pact = Pact()
      ..consumer = (Consumer()..name = 'consumer-for-mock-server')
      ..provider = (Provider()..name = 'provider-for-mock-server')
      ..interactions = [interaction];
    final contractAsJsonString = json.encode(pact);

    MockServer createServer() {
      const host = '127.0.0.1';
      var serverPort = bindings.createMockServer(_ffiLib, contractAsJsonString,
          host: host, port: port ?? 0);
      return MockServer._(host, serverPort, _ffiLib, interaction);
    }

    if (port == null) {
      var server = createServer();
      _servers[server.port] = server;
      return server;
    }

    return _servers.update(
        port,
        (existing) =>
            throw PactException('Server with port $port already exists'),
        ifAbsent: createServer);
  }

  /// Tries to close all servers that weren't closed explicitly.
  ///
  /// Returns true if all servers were closed of false if any of them couldn't
  /// be closed.
  bool close() {
    return _servers.values.fold(
        true, (previousValue, element) => previousValue && element._close());
  }

  /// Creates a server factory from the defaults.
  ///
  /// [libPath] can be used to provide a different path for the rust core
  /// library. **Using a different library version has unpredictable results**.
  static Future<MockServerFactory> create({String? libPath}) async {
    final libPathNn = libPath ?? _default_lib_path;
    var file = File(libPathNn);
    if (!await file.exists()) {
      throw PactException('Library $libPathNn not found.'
          'Try to run dart "pub run dart_pact_consumer:github_download" to get it from Github');
    }

    var lib = bindings.open(libPathNn);
    return MockServerFactory._(lib);
  }

  bool closeServer(MockServer server) {
    return _servers.remove(server.port)?._close() ?? false;
  }
}

class MockServer {
  final int port;
  final String host;
  static const String schema = 'http';
  final Interaction interaction;
  final DynamicLibrary _ffiLib;
  var _closed = false;

  String get address => '$schema://$host:$port';

  MockServer._(this.host, this.port, this._ffiLib, this.interaction);

  /// Tries to close an open server. Returns true if closed.
  /// Can return false if the call fails or the server no longer exists.
  ///
  /// Its safe to call this function even after closing.
  bool _close() {
    if (!_closed) {
      _closed = bindings.cleanup(_ffiLib, port);
    }
    return _closed;
  }

  bool hasMatched() {
    _assertNotClosed();
    return bindings.hasServerMatched(_ffiLib, port);
  }

  void _assertNotClosed() {
    assert(!_closed, 'Server is closed');
  }

  /// Returns a Json representation of all the mismatches that the server contains.
  String getMismatchJson() {
    _assertNotClosed();
    return bindings.getJsonMismatch(_ffiLib, port);
  }
}

extension MockServerExt on MockServer {
  Future<HttpClientResponse> invoke(
    String path, {
    String method = 'GET',
    Object? body,
    Map<String, String> headers = const {'accept': 'application/json'},
    int status = 200,
  }) async {
    final client = HttpClient();
    final uri = Uri.parse('$address$path');
    final req = await client.openUrl(method, uri);
    headers.forEach((key, value) {
      req.headers.add(key, value);
    });
    body?.let(req.write);
    var response = await req.close();
    if (response.statusCode != status) {
      var message = 'Expecting status $status but got '
          '${response.statusCode} on $method $uri.';
      if (!hasMatched()) {
        message += '\n ${getMismatchJson()}';
      }
      throw PactException(message);
    }
    return response;
  }
}
