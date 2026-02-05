
> This script builds Aseprite for the latest Apple Silicon Macs. A minimum of **macOS 11 (Big Sur)** is required to run the script.

## Table of Contents

- [Why](#why)
- [Requirements](#requirements)
- [Build Instructions](#build-instructions)
- [Caveats](#caveats)
- [Shameless Plug](#shameless-plug)
- [License](#License)

## Why

Aseprite is a powerful tool for creating pixel art and animations, and as a hobby, I've been doing pixel art for quite a while. However, building it on my MacBook was a challenging process. Thus, I've made this script which aims to simplify the build process by automating all of the steps, requiring little to no manual input.

## Requirements

> [!NOTE]
> The script has been successfully tested with **macOS Tahoe 26**.

Dependencies you have to install:

- [Xcode](https://developer.apple.com/xcode/)
- [Homebrew](https://brew.sh)

Dependencies the program automatically attempts to install:

- [CMake](https://cmake.org/)
- [Ninja](https://ninja-build.org/)
- [libyaml](https://github.com/yaml/libyaml)
- [Git](https://git-scm.com/)

If you want to install the dependencies manually though, use this Homebrew command:

```bash
brew install libyaml cmake ninja git
```

## Instructions

1. Clone the repository:

```bash
git clone https://github.com/hitblast/aseprite-build-apple.git
```

2. Run these commands in a row:

```bash
cd aseprite-build-apple

chmod +x build.sh

./build.sh
```

## Caveats

- The script temporarily unsets the `CC` and `CXX` environment variables during execution since Aseprite's source code does not behave well with it.

## Icon Credits

Link: https://macosicons.com/#/?icon=Knq8aGmihZ

The Aseprite icon has been downloaded from [macOS Icons](https://macosicons.com/). Thanks to [patrick-l](https://macosicons.com/#/u/patrick-l) for making this icon.

## Shameless Plug

I've started working on my own solo open-source organization for Mac software. Maybe you can [check it out](https://machlit.github.io) while you're at it; I focus on automation and nifty goodie-like tools to sweeten up the average Mac experience in a terminal-friendly way.

## License

This repo is under [Apache License (Version 2.0)](./LICENSE).
