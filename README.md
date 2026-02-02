# ✨ Aseprite Build Script for Apple Silicon

This script builds Aseprite for the latest Apple Silicon Macs. A minimum of **macOS 11 (Big Sur)** is required to run the script.

## Table of Contents

- [Why](#why)
- [Requirements](#requirements)
- [Build Instructions](#build-instructions)
- [Caveats](#caveats)
- [License](#License)

## Why

Aseprite is a powerful tool for creating pixel art and animations, and as a hobby, I've been doing pixel art for quite a while. However, building it on my MacBook was a challenging process. Thus, I've made this script which aims to simplify the build process by automating all of the steps, requiring little to no manual input.

## Requirements

> [!NOTE]
> The script has been successfully tested with **macOS Tahoe 26**.

- [Xcode](https://developer.apple.com/xcode/)
- [CMake](https://cmake.org/)
- [Ninja](https://ninja-build.org/)
- [libyaml](https://github.com/yaml/libyaml)
- [Git](https://git-scm.com/)

If you want to install the dependencies, use this Homebrew command:

```bash
brew install libyaml cmake ninja git
```

## Instructions

1. Clone the repository:

```bash
# Clone using git.
git clone https://github.com/hitblast/aseprite-build-apple.git
```

2. Run the script:

```bash
# Change directory to the script.
cd aseprite-build-apple

# Make the script executable.
chmod +x build.sh

# Run the script.
./build.sh
```

## Caveats

- The script temporarily unsets the `CC` and `CXX` environment variables during execution since Aseprite's source code does not behave well with it.

## License

This repo is under [Apache License (Version 2.0)](./LICENSE).
