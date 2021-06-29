import 'dart:convert';

import 'package:dart_pact_consumer/dart_pact_consumer.dart';
import 'package:dart_pact_consumer/src/ffi/rust_mock_server.dart';
import 'package:dart_pact_consumer/src/functional.dart';
import 'package:dart_pact_consumer/src/json_serialize.dart';
import 'package:dart_pact_consumer/src/pact_contract_dto.dart';
import 'package:dart_pact_consumer/src/pact_host_client.dart';

import 'pact_exceptions.dart';

/// Holder for pacts in their builder form.
///
/// Can merge several builders into a single [Pact] with all the combined
/// interactions
class PactRepository {
  final Map<String, Pact> _pacts = {};
  final bool requireTests;

  PactRepository({this.requireTests = true});

  /// Adds all the request-response pairs as interactions in a [Pact] structure.
  void add(PactBuilder builder) {
    builder.validate(requireTests: requireTests);
    final contract = _pacts.putIfAbsent(
        _key(builder.consumer, builder.provider), () => _createHeader(builder));
    _mergeInteractions(builder, contract);
  }

  /// Publishes all pacts onto a host with tagging a specific version
  Future<void> publish(PactHost host, String version) {
    if (RequestTester.hasErrors) {
      throw PactException("Can't publish when there are tests with errors");
    }
    final futures = _pacts.values.map((e) => host.publishContract(e, version));
    return Future.wait(futures);
  }

  /// Gets a pact file in JSON format
  String getPactFile(String consumer, String provider) {
    return _pacts[_key(consumer, provider)].let((value) {
      return jsonEncode(value);
    });
  }

  static String _key(String consumer, String provider) =>
      '${consumer}|${provider}';

  static Pact _createHeader(PactBuilder builder) {
    return Pact()
      ..provider = (Provider()..name = builder.provider)
      ..consumer = (Consumer()..name = builder.consumer);
  }

  static void _mergeInteractions(PactBuilder builder, Pact contract) {
    final interactions = builder.stateBuilders.expand(
        (st) => st.requests.map((req) => _toInteraction(req, st.state)));
    contract.interactions.addAll(interactions);
  }

  static Interaction _toInteraction(
      RequestBuilder requestBuilder, String state) {
    return Interaction()
      ..description = requestBuilder.description
      ..providerStates = [ProviderState()..name = state]
      ..request = (_toRequest(requestBuilder))
      ..response = (_toResponse(requestBuilder.response));
  }

  static Request _toRequest(RequestBuilder requestBuilder) {
    return Request()
      ..method = _toMethod(requestBuilder.method)
      ..path = requestBuilder.path
      ..query = requestBuilder.query
      ..body = requestBuilder.body
      ..headers = requestBuilder.headers;
  }

  static Response _toResponse(ResponseBuilder response) {
    return Response()
      ..headers = response.headers
      ..status = response.status.code
      ..body = response.body;
  }

  static String _toMethod(Method method) {
    const prefix = 'Method.';
    return method.toString().substring(prefix.length);
  }
}

typedef RequestTestFunction = Future<dynamic> Function(MockServer server);

class RequestTester {
  final StateBuilder _stateBuilder;

  // todo shouldn't be static
  static bool hasErrors = false;

  RequestTester._(this._stateBuilder);

  void test(MockServerFactory factory, RequestTestFunction testFunction) async {
    final pactBuilder = PactBuilder()..stateBuilders.add(_stateBuilder);
    final pact = PactRepository._createHeader(pactBuilder);
    PactRepository._mergeInteractions(pactBuilder, pact);
    final server = factory.createMockServer(pact.interactions[0]);
    try {
      await testFunction(server);
      _stateBuilder._tested = true;
      if (!server.hasMatched()) {
        hasErrors = true;
        final mismatchJson = server.getMismatchJson();
        throw PactMatchingException(mismatchJson);
      }
    } finally {
      factory.closeServer(server);
    }
  }
}

/// DSL for building pact contracts.
///
/// Builds an interaction for each state-request-response tuple.
///
/// This DSL doesn't match with the formal specification by design.
/// For instance, the state is mandatory and only after that we can define
/// the requests.
/// These changes makes reasoning about pacts easier.
///
/// Not all features are available at first, but can be added as needed:
/// . Request matchers
/// . Generators
/// . Encoders
class PactBuilder {
  String consumer;
  String provider;
  final List<StateBuilder> _states = [];

  PactBuilder();

  List<StateBuilder> get stateBuilders => _states;

  // builder functions allow to change internals in the future
  RequestTester addState(void Function(StateBuilder stateBuilder) func) {
    final builder = StateBuilder._();
    func(builder);
    _states.add(builder);
    return RequestTester._(builder);
  }

  void validate({bool requireTests = true}) {
    assert(consumer != null);
    assert(provider != null);
    stateBuilders.forEach((element) => element._validate(requireTests));
  }
}

enum Method { GET, POST, DELETE, PUT }

class StateBuilder {
  String state;
  bool _tested = false;

  final List<RequestBuilder> requests = [];

  void _validate(bool requireTests) {
    assert(state != null);
    assert(requests != null);
    assert(requests.isNotEmpty);
    if (requireTests && !_tested) {
      throw PactException('State "$state" not tested');
    }
    requests.forEach((element) => element._validate());
  }

  void addRequest(void Function(RequestBuilder reqBuilder) func) {
    final builder = RequestBuilder._();
    func(builder);
    requests.add(builder);
  }

  StateBuilder._();
}

class RequestBuilder {
  String _path = '/';

  String get path => _path;

  set path(String path) {
    if (path.startsWith('/')) {
      _path = path;
    } else {
      _path = '/$path';
    }
  }

  String description = '';
  Method method = Method.GET;
  ResponseBuilder _response;

  Map<String, String> query = {};

  ResponseBuilder get response => _response;
  Body body = Body.isNullOrAbsent();

  Map<String, String> headers = {};

  void setResponse(void Function(ResponseBuilder respBuilder) func) {
    final builder = ResponseBuilder._();
    func(builder);
    _response = builder;
  }

  void _validate() {
    assert(_path != null);
    assert(_path != '');
    assert(query != null);
    assert(method != null);
    assert(_response != null);
    assert(body != null);
    assert(headers != null);
    _response._validate();
  }

  RequestBuilder._();
}

class ResponseBuilder {
  Map<String, String> headers = {};

  Status status = Status(200);

  Body body = Body.empty();

  void _validate() {
    assert(headers != null);
    assert(status != null);
    assert(body != null);
  }

  ResponseBuilder._();
}

// https://github.com/pact-foundation/pact-specification/tree/version-3#semantics-around-body-values
/// Models a request/response body.
class Body extends Union3<Json, String, Unit> implements CustomJson {
  /// Body must be a Json object
  Body.json(Json json) : super.t1(json);

  /// Body must be a string
  Body.string(String str)
      : assert(str.isNotEmpty),
        super.t2(str);

  /// Body must be empty
  Body.empty() : super.t2('');

  /// Body is explicitly null or is absent.
  ///
  /// [Doc](https://github.com/pact-foundation/pact-specification/tree/version-3#body-is-present-but-is-null)
  Body.isNullOrAbsent() : super.t3(unit);

  @override
  dynamic toJson() {
    return fold(
      (js) => js.toJson(),
      (str) => str,
      (unit) => unit.toJson(),
    );
  }

  static Body fromJsonToBody(dynamic body) {
    if (body == null) {
      return Body.isNullOrAbsent();
    }

    if (body == '') {
      return Body.empty();
    }

    if (body is String) {
      return Body.string(body);
    }

    if (body is Map<String, dynamic>) {
      return Body.json(Json.object(body));
    }

    if (body is Iterable<dynamic>) {
      return Body.json(Json.array(body));
    }
    throw AssertionError('Unknown body type ${body.runtimeType}');
  }
}

/// Models a Json object.
///
/// The definition is relaxed to dynamic to allow more flexibility. No need
/// to create unions for every valid Json type.
///
/// Designed to work with custom Json objects or to interoperate with
/// classes that comply with the Json serialization conventions.
class Json extends Union2<Iterable<dynamic>, Map<String, dynamic>>
    implements CustomJson {
  Json.object(Map<String, dynamic> json) : super.t2(json);

  Json.array(Iterable<dynamic> json) : super.t1(json);

  @override
  dynamic toJson() {
    return fold(
      (arr) => arr,
      (obj) => obj,
    );
  }
}

class Status {
  final int code;

  static final Status ok = Status(200);
  static final Status created = Status(201);

  Status(this.code) : assert(code >= 100 && code <= 599);
}
