
import 'dart:convert';
import 'dart:io';

import 'package:dart_pact_consumer/src/functional.dart';
import 'package:dart_pact_consumer/src/json_serialize.dart';
import 'package:dart_pact_consumer/src/pact_contract_dto.dart';

class ContractRepository {
  final Map<String, Contract> contracts = {};
  HttpClient _client;

  ContractRepository({HttpClient client}): _client = client;

  void add(ContractBuilder builder) {
    builder.validate();
    final contract =
        contracts.putIfAbsent(_key(builder), () => _create(builder));
    _merge(builder, contract);
  }

  Future<void> publish(String host, String version, {List<String> tags}) {
    final futures = contracts.values
        .map((e) => _publishContract('$host/pacts', version, e));
    return Future.wait(futures);
  }

  Future<void> _publishContract(
      String baseUri, String version, Contract contract) async {
    final urlStr = '$baseUri/provider/${contract.provider.name}/consumer/'
        '${contract.consumer.name}/version/$version';
    _client ??= HttpClient();

    var uri = Uri.parse(urlStr);
    final request = await _client.putUrl(uri);
    request.headers.contentType = ContentType.json;
    request.write(jsonEncode(contract.toJson()));

    final response = await request.close();

    var statusCode = response.statusCode;
    if (statusCode > 299) {
      throw HttpException('Status code not success: $statusCode.'
          'Reason: ${response.reasonPhrase}', uri: uri);
    }
  }

  String _key(ContractBuilder builder) =>
      '${builder.consumer}|${builder.provider}';

  Contract _create(ContractBuilder builder) {
    return Contract()
      ..provider = (Provider()..name = builder.provider)
      ..consumer = (Consumer()..name = builder.consumer);
  }

  void _merge(ContractBuilder builder, Contract contract) {
    final interactions = builder.stateBuilder.expand(
        (st) => st.requests.map((req) => _toInteraction(req, st.state)));
    contract.interactions.addAll(interactions);
  }

  Interaction _toInteraction(RequestBuilder requestBuilder, String state) {
    return Interaction()
      ..description = requestBuilder.description
      ..providerStates = [ProviderState()..name = state]
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
class ContractBuilder {
  String consumer;
  String provider;
  List<StateBuilder> _states = [];

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

  Status(this.code) : assert(code >= 100 && code <= 599);
}