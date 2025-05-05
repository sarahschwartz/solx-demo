# `solx` compiler demo

[`solx`](https://github.com/matter-labs/solx) is a new optimizing compiler for EVM, developed by [Matter Labs](https://matter-labs.io/).

This repository contains a playground to test `solx` capabilities.

> [!WARNING]  
> `solx` is in pre-alpha state and not suitable for production use.

## Installing

Install [foundry](https://book.getfoundry.sh/getting-started/installation) to interact with the projects.
Foundry v1.0.0 can be used.

Here are the URL for the [test builds](https://github.com/matter-labs/solx/releases).

Choose the appropriate binary to download based on your OS, download it to the `bin` folder, and rename it to `solx`.

Next, run the command below to make it executable, e.g.:

```bash
chmod +x bin/solx
```

You can verify that this worked by checking the version:

```bash
./bin/solx --version
```

## Using with forge

By default, all the projects will use native `solc` 0.8.28, to compile with `solx` use `FOUNDRY_PROFILE=solx`, e.g.:

```bash
FOUNDRY_PROFILE=solx forge build
FOUNDRY_PROFILE=solx forge test
```

Or you can do `export FOUNDRY_PROFILE=solx` to make it used by default within your terminal session.

Please check which version is used for compilation: `0.8.28` corresponds to native `solc`, while `0.8.29` corresponds to `solx`.
The main reason to use different versions of compiler is to force foundry to recompile contracts when switching profiles.
`0.8.29` release of `solc` doesn't seem to have new optimizations, so it shouldn't affect comparisons. Feel free to compare
with other versions yourself.

`solx` is still very early in development. Here are some guidelines:

- Run `forge build` before running tests, and run `forge clean` after running tests. Re-compilation of already built contracts may not work as expected.
- `stack too deep` and `bytecode size is too big` errors may be very frequent; the work on optimizations required to prevent that is ongoing.
- Only `forge build` & `forge test` were checked; `forge script` and other options may not work or work incorrectly.
- Legacy codegen is more stable for now, `via_ir` does not work with `solmate` project.

## Comparisons

You can compare the gas snapshots of the tests using the `snapshots.sh` script.

```bash
bash scripts/snapshots.sh
```

There comparisons aren't meant to be considered proper benchmarks. Consider these comparisons to be "out-of-box", e.g. something
user will get with default settings for both compilers. Do your own research, and compare compiler performance for your
use case.

Additionally, consider that `solx` is still in a pre-alpha stage and many optimizations are not implemented yet!
