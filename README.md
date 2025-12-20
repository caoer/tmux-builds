# tmux releases

This repository provides ready to use binaries of the [tmux](https://github.com/tmux/tmux/) terminal multiplexer.

## Available Releases

All releases are available in the [Releases](https://github.com/ll-nick/tmux-releases/releases) section.  

Supported platforms:
- Linux x86_64
- Linux arm64
- macOS x86_64
- macOS arm64 (Apple Silicon)

> **Note:** The macOS binaries are not fully static due to system library dependencies.  
> No external dependencies beyond a standard macOS installation are required.

Two types of builds are provided:

- **Release builds:** Stable versions of tmux (e.g., v3.6a).  
- **Nightly builds:** Built from the latest `master` commit; may include experimental features or unstable changes.

## Installation

1. Go to the [Releases](https://github.com/ll-nick/tmux-releases/releases) page.  
2. Download the archive for your platform.  
3. Extract the archive with:
 
   ```bash
   tar -xzf tmux-<version>-<platform>.tar.gz
   ```

4. Move the binary to a directory in your `PATH`, e.g.:

   ```bash
   sudo mv tmux /usr/local/bin
   ```

## Local Build Instructions

### Via Docker (Linux only)

Adjust dependency versions in `versions.env` if needed.  

Set the tmux version via build argument or environment variable:

```bash
docker compose build --build-arg TMUX_VERSION=3.5a
# or
TMUX_VERSION=3.5a docker compose build
```

Extract the binary:

```bash
docker compose create tmux-release-builder
docker cp tmux-release-builder:/artifacts ./artifacts
docker compose rm tmux-release-builder
```

### Via Build Scripts

You can alternatively build tmux directly on your machine using the provided [build scripts](./scripts/).  
See the build stage for you platform in the [GitHub Actions workflow](.github/workflows/create-release.yml) reference on how to use these scripts.

## Acknowledgments

The build scripts are inspired by the [build-static-tmux](https://github.com/mjakob-gh/build-static-tmux) repository by mjakob-gh.

