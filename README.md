## tmux releases

This repository provides precompiled binaries of the [tmux](https://github.com/tmux/tmux/) terminal multiplexer.

> **Note:** This repository is under construction.

### Available Releases

You can find the available tmux releases in the [Releases](https://github.com/ll-nick/tmux-releases/releases) section of this repository.
Each release includes statically compiled binaries for various architectures.
As of right now, only Linux binaries are provided.

### Local Build Instructions

You can build a tmux binary locally using Docker.
Set the desired tmux and dependency versions in `versions.env`.
Then run the following commands:

```bash
docker compose build

docker compose create tmux-release-builder
docker cp tmux-release-builder:/artifacts ./artifacts
docker compose rm tmux-release-builder
```

### Acknowledgments

The build scripts are inspired by the great work done in the [build-static-tmux](https://github.com/mjakob-gh/build-static-tmux) repository by mjakob-gh.
