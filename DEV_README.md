# Development

## FFI compatibility

The bindings work with a specific version of the rust library. There are no compilation time checks for this.

If all planets align is even possible to write code that runs, but gives incorrect results due to incompatible bindings.

## Pact DTO generation
`dart pub run build_runner build --delete-conflicting-outputs`

## Integration tests

Docker setup in the [docker](./docker) folder.

Then launch the integration tests with `dart test integration_test`
