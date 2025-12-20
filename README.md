## tmux releases

This repository provides static pre-compiled binaries of the [tmux](https://github.com/tmux/tmux/) terminal multiplexer.

### Available Releases

You can find the available tmux releases in the [Releases](https://github.com/ll-nick/tmux-releases/releases) section of this repository.
Currently, the following platforms are supported:
- Linux x86_64
- Linux arm64
- macOS x86_64
- macOS arm64 (Apple Silicon)

> **Note:** The macOS binaries are not technically fully static due to system library dependencies.
> This is a platform limitation.
> However, no external dependencies beyond what is included in a standard macOS installation are required.

### Local Build Instructions

#### Via Docker (Linux only)

If required, adjust the dependency versions in `versions.env`.
The tmux version can be set via the `TMUX_VERSION` build argument.
Pass it via the `--build-arg` option 

```bash
docker compose build --build-arg TMUX_VERSION=3.5a
```

or set it via an environment variable:

```bash
TMUX_VERSION=3.5a docker compose build
```

To extract the built tmux binary, run the following commands:

```bash
docker compose create tmux-release-builder
docker cp tmux-release-builder:/artifacts ./artifacts
docker compose rm tmux-release-builder
```

#### Via Build Scripts

You can alternatively build tmux directly on your machine using the scripts provided in the `scripts/` directory.
See the build stage for you platform in the [GitHub Actions workflow](.github/workflows/create-release.yml) reference on how to use these scripts.

### Acknowledgments

The build scripts are inspired by the great work done in the [build-static-tmux](https://github.com/mjakob-gh/build-static-tmux) repository by mjakob-gh.
