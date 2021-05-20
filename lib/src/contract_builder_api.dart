
import 'dart:convert';
import 'dart:io';

import 'package:dart_pact_consumer/src/functional.dart';
import 'package:dart_pact_consumer/src/json_serialize.dart';
import 'package:dart_pact_consumer/src/pact_contract_dto.dart';
import 'package:dart_pact_consumer/src/pact_host_client.dart';

/// Holder for pacts in their build form.
///
/// Can merge several builders into a single [Pact] with all the combined
/// interactions
class PactRepository {
  final Map<String, Pact> pacts = {};
  PactRepository();

  /// Adds all the request-response pairs as interactions in a [Pact] structure.
  void add(PactBuilder builder) {
    builder.validate();
    final contract =
        pacts.putIfAbsent(_key(builder), () => _create(builder));
    _merge(builder, contract);
  }

  Future<void> publish(PactHost host, String version) {
    final futures = pacts.values
        .map((e) => host.publishContract(e, version));
    return Future.wait(futures);
  }

  String _key(PactBuilder builder) =>
      '${builder.consumer}|${builder.provider}';

  Pact _create(PactBuilder builder) {
    return Pact()
      ..provider = (Provider()..name = builder.provider)
      ..consumer = (Consumer()..name = builder.consumer);
  }

  void _merge(PactBuilder builder, Pact contract) {
    final interactions = builder.stateBuilder.expand(
        (st) => st.requests.map((req) => _toInteraction(req, st.state)));
    contract.interactions.addAll(interactions);
  }

  Interaction _toInteraction(RequestBuilder requestBuilder, String state) {
    return Interaction()
      ..description = requestBuilder.description
      ..providerStates = [ProviderState()..name = state]
      ..type = requestBuilder.type.value
      ..request = (_toRequest(requestBuilder))
      ..response = (_toResponse(requestBuilder.response));
  }

  Request _toRequest(RequestBuilder requestBuilder) {
    return Request()
      ..method = _toMethod(requestBuilder.method)
      ..path = requestBuilder.path
      ..query = requestBuilder.query
      ..body = requestBuilder.body
      ..headers = requestBuilder.headers;
  }

  Response _toResponse(ResponseBuilder response) {
    return Response()
      ..headers = response.headers
      ..status = response.status.code
      ..body = response.body;
  }

  String _toMethod(Method method) {
    const prefix = 'Method.';
    return method.toString().substring(prefix.length);
  }
}

/// DSL for building pact contracts.
///
/// Builds an interaction for each state-request-response tuple.
///
/// This DSL doesn't match with the formal specification to simplify contracts.
/// For instance, it is possible that a single interaction sets multiple states.
/// It is flexible, but is a source for bugs, since the states may create
/// conflicting changes on the provider. Other libraries like the JVM one also
/// don't allow multiple states.
///
/// Not al features are available at first, but can be added as needed:
/// . Request matchers
/// . Generators
/// . Encoders
class PactBuilder {
  String consumer;
  String provider;
  final List<StateBuilder> _states = [];

  List<StateBuilder> get stateBuilder => _states;

  // builder functions allow to change internals in the future
  void addState(void Function(StateBuilder builder) func) {
    final builder = StateBuilder._();
    func(builder);
    _states.add(builder);
  }

  void validate() {
    assert(consumer != null);
    assert(provider != null);
    stateBuilder.forEach((element) => element._validate());
  }
}

enum Method { GET, POST, DELETE, PUT }

class InteractionType {
  final String value;
  InteractionType._(this.value);

  static InteractionType SYNCHRONOUS_HTTP = InteractionType._('Synchronous/HTTP');
}

class StateBuilder {
  String state;

  final List<RequestBuilder> requests = [];

  void _validate() {
    assert(state != null);
    assert(requests != null);
    requests.forEach((element) => element._validate());
  }

  void addRequest(void Function(RequestBuilder builder) func) {
    final builder = RequestBuilder._();
    func(builder);
    requests.add(builder);
  }

  StateBuilder._();
}

class RequestBuilder {
  String path;
  String description = '';
  Method method = Method.GET;
  InteractionType type = InteractionType.SYNCHRONOUS_HTTP;
  ResponseBuilder _response;

  Map<String, String> query = {};

  ResponseBuilder get response => _response;
  Body body = Body.none();

  Map<String, String> headers = {};

  void setResponse(void Function(ResponseBuilder builder) func) {
    final builder = ResponseBuilder._();
    func(builder);
    _response = builder;
  }

  void _validate() {
    assert(path != null);
    assert(query != null);
    assert(method != null);
    assert(type != null);
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

  Body body = Body.none();

  void _validate() {
    assert(headers != null);
    assert(status != null);
    assert(body != null);
  }

  ResponseBuilder._();
}

/// Models a request/response body.
class Body extends Union3<Json, String, Unit> implements CustomJson {
  Body.json(Json json) : super.t1(json);

  Body.string(String str) : super.t2(str);

  Body.none() : super.t3(unit);

  @override
  dynamic toJson() {
    return fold(
      (js) => js.toJson(),
      (str) => str,
      (unit) => unit.toJson(),
    );
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

  Status(this.code) : assert(code >= 100 && code <= 599);
}
