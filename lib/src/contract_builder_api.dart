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
    final contract = pacts.putIfAbsent(_key(builder), () => _create(builder));
    _merge(builder, contract);
  }

  Future<void> publish(PactHost host, String version) {
    final futures = pacts.values.map((e) => host.publishContract(e, version));
    return Future.wait(futures);
  }

  String _key(PactBuilder builder) => '${builder.consumer}|${builder.provider}';

  Pact _create(PactBuilder builder) {
    builder.validate();

    return Pact(
      provider: Provider(name: builder.provider),
      consumer: Consumer(name: builder.consumer),
    );
  }

  void _merge(PactBuilder builder, Pact contract) {
    final interactions = builder.stateBuilder.expand(
      (st) {
        st._validate();

        return st.requests.map(
          (req) => _toInteraction(req, st.state),
        );
      },
    ).toList();

    if (interactions.isNotEmpty && contract.interactions == null) {
      contract.interactions = interactions;
    } else if (interactions.isNotEmpty && contract.interactions != null) {
      contract.interactions!.addAll(interactions);
    }
  }

  Interaction _toInteraction(RequestBuilder requestBuilder, String? state) {
    requestBuilder._validate();

    return Interaction(
      description: requestBuilder.description,
      // RESEARCH: Where are the params and multiple states gonna come from?
      providerStates: state == null ? [] : [ProviderState(name: state)],
      request: (_toRequest(requestBuilder)),
      response: (_toResponse(requestBuilder.response)),
    );
  }

  Request _toRequest(RequestBuilder requestBuilder) {
    return Request(
      method: _toMethod(requestBuilder.method),
      path: requestBuilder.path,
      query: requestBuilder.query,
      body: requestBuilder.body,
      headers: requestBuilder.headers,
    );
  }

  Response _toResponse(ResponseBuilder response) {
    return Response(
      headers: response.headers,
      status: response.status.code,
      body: response.body,
    );
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

  PactBuilder({
    required this.consumer,
    required this.provider,
  });

  // builder functions allow to change internals in the future
  void addState(void Function(StateBuilder builder) func) {
    final builder = StateBuilder._();
    func(builder);
    _states.add(builder);
  }

  void validate() {
    stateBuilder.forEach((element) => element._validate());
  }
}

enum Method { GET, POST, DELETE, PUT }

class StateBuilder {
  String? state;
  List<RequestBuilder> requests = [];

  StateBuilder._();

  void _validate() {
    assert(state != null);
    requests.forEach((element) => element._validate());
  }

  void addRequest(void Function(RequestBuilder builder) func) {
    final builder = RequestBuilder._();
    func(builder);
    requests.add(builder);
  }
}

class RequestBuilder {
  String? path;
  String? description = '';
  Method method = Method.GET;
  ResponseBuilder? _response;
  Map<String, String>? query;
  Map<String, String>? headers;
  Body? body;

  ResponseBuilder get response {
    assert(_response != null);
    return _response!;
  }

  RequestBuilder._();

  void setResponse(void Function(ResponseBuilder builder) func) {
    final builder = ResponseBuilder._();
    func(builder);
    _response = builder;
  }

  void _validate() {
    assert(path != null);
    assert(_response != null);
  }
}

class ResponseBuilder {
  Map<String, String>? headers;
  Status status = Status(200);
  Body? body;

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

  Status(this.code) : assert(code >= 100 && code <= 599);
}
