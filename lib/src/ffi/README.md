## notes

- allocate and free are manual. not good
- need native libraries for os/arch
- RUST ffi https://docs.rs/pact_mock_server_ffi/0.1.1/pact_mock_server_ffi
- foreign code runs on an Isolate base. may be useful to clean resources
- PACT_MOCK_LOG_LEVEL variable name
- server ports are used to differentiate interactions on pacts. 
  a server is started with either a JSON pact or a pact handle. requests are done to it
  and we can write it down to file system.

## questions
- how many pact versions the mock server supports?
- how can we set the provider state when testing?
  - we can't set the mock server to use a specific state, not designed for that

## Conclusions
### ffi only support custom structs as of 2.12
Can't build pact file with library.
