# Development

## FFI compatibility

The bindings work with a specific version of the rust library. There are no compilation time checks for this.

If all planets align is even possible to write code that runs, but gives incorrect results due to incompatible bindings.

## Pact DTO generation
`dart run build_runner build --delete-conflicting-outputs`

## Unit test
Download the ffi library from github `dart run dart_pact_consumer:github_download`

Run `dart test`

## Integration tests

Docker setup in the [docker](./docker) folder.

Then launch the integration tests with `dart test integration_test`
