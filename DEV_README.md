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

Launch the pact broker container in the [compose](./docker/docker-compose.yaml) file.

Run the tests specifying the `PACT_HOST` flag in a `define` parameter. The test command doesn't respect the values
passed as environment ([issue](https://github.com/dart-lang/sdk/issues/44562)), so we need to run each test
individually with the `run` command.

Or use the script `ls integration_test | xargs -i dart -DPACT_HOST=[broker] run integration_test/{}`.
