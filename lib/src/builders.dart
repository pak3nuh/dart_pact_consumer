import 'package:dart_pact_consumer/src/models/matching_rules.dart';

import 'models/body.dart';
import 'models/serializable/all.dart';
import 'models/status.dart';

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
    final query = Uri(queryParameters: requestBuilder.query).query;
    final decodedQuery = query.isEmpty ? null : Uri.decodeComponent(query);

    return Request(
      method: _toMethod(requestBuilder.method),
      path: requestBuilder.path,
      query: decodedQuery,
      body: requestBuilder.body,
      headers: requestBuilder.headers,
      matchingRules: requestBuilder.matchingRules,
    );
  }

  Response _toResponse(ResponseBuilder responseBuilder) {
    return Response(
      headers: responseBuilder.headers,
      status: responseBuilder.status.code,
      body: responseBuilder.body,
      matchingRules: responseBuilder.matchingRules,
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
  MatchingRules? matchingRules;

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
  MatchingRules? matchingRules;

  ResponseBuilder._();
}
