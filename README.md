# Dart Pact Consumer

Dart library to build pact contracts, test and publish them to a broker.

## Lifecycle

### Set up the infrastructure
Set up the support structures for the definitions and tests. 

```dart
final repository = PactRepository();
final serverFactory = await MockServerFactory.create();
```

#### Mock server
The mock server requires an external library to launch, made by the team behind pact. This package uses defaults to
load such library but it needs to be downloaded previously.

To use the defaults run `dart pub run dart_pact_consumer:github_download`.

### Define each interaction
```dart
final pactBuilder = PactBuilder()
    ..consumer = 'consumer'
    ..provider = 'provider';

final interactionTester = pactBuilder.addState((state) {
    state.state = 'Given empty pet list';
    state.addRequest((request) {
      request
        ..method = Method.POST
        ..headers = { 'accept': 'application/json' }
        ..path = '/pets'
        ..description = 'Post a pet'
        ..body = Body.json(Json.object({'name': 'Bob'}))
        ..setResponse((response) {
          response
            ..status = Status.created
            ..body = Body.isNullOrAbsent();
        });
    });
});
```

In this package, the state is handled differently from the specification. This is done intentionally to
streamline pact files and make them easier to reason about.

To make a request, you need to tell in which state the provider must be in, therefore eliminating any default implicit
state and carry overs from other requests.

### Match the interactions on the mock server
Use the mock server to ensure the interactions are OK and add them to the repository.

**Notice**: Testing the interaction is not mandatory because Dart FFI is not stable in this release. 
If there are problems with the mock library integration, we can still build valid pacts files.

```dart
await interactionTester.test(
  serverFactory,
  (server) => server.invoke('/pets',method: 'POST', status: 201, body: '''{"name":"Bob"}'''),
); 

repository.add(pactBuilder);
```

The `server.invoke` result is the response given by the server, so additional validations can be done here.

### Publish the interactions as a pact contract to a broker
```dart
teardownAll(() {
  serverFactory.close();
  repository.publish(PactHost('broker uri'), 'pact version');
});
```

If there were tests with mismatches, then the publishing will fail.

## Pact repository
The repository is a piece introduced to improve flexibility. As a developer I don't want to make HTTP calls
that may break the tests due to external factors, so the publish step can be extracted to integration tests.

With a little bit of clever refactoring is possible to run the test cases in the unit test phase and run them again
in the integration test to publish the contract to the broker.

Flutter has a specific setup for [integration tests](https://flutter.dev/docs/cookbook/testing/integration/introduction)
, but dart doesn't need one. Since all code in dart lives as source
files, it is just a matter of creating a file with an entry point that gets invoked with `dart run path-to-file.dart`.

## Stability

This package has not reached stable status yet. API and functionality are likely to change.

Stable status will be reached on version `1.0.0`.
