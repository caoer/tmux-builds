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

For Linux targets, you can build a tmux binary locally using Docker.
Set the desired tmux and dependency versions in `versions.env`.
Then run the following commands:

```bash
docker compose build

docker compose create tmux-release-builder
docker cp tmux-release-builder:/artifacts ./artifacts
docker compose rm tmux-release-builder
```

On macOS, you can build tmux directly on your machine using the scripts provided in the `scripts/` directory.
See the GitHub Actions workflow files in the `.github/workflows/` directory for reference on how to use these scripts.

### Acknowledgments

The build scripts are inspired by the great work done in the [build-static-tmux](https://github.com/mjakob-gh/build-static-tmux) repository by mjakob-gh.
