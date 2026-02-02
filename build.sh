#!/bin/zsh
emulate -LR zsh

LATEST_RELEASE=$(curl -s https://api.github.com/repos/aseprite/aseprite/releases/latest | grep -o '"tag_name": "[^"]*"' | cut -d'"' -f4)

# Export paths and URLs
export ROOT=$PWD
export DEPS=$ROOT/deps
export ASEPRITE=$DEPS/aseprite
export SKIA=$DEPS/skia
export ASEZIP=$(curl -s https://api.github.com/repos/aseprite/aseprite/releases/latest | grep -o '"browser_download_url": "[^"]*"' | cut -d'"' -f4)
export SKIAZIP=https://github.com/aseprite/skia/releases/download/m124-08a5439a6b/Skia-macOS-Release-arm64.zip
export ARCH=arm64

if which -s cmake && \
   which -s ninja && \
   { [ -n "$(ls /usr/local/include/yaml.h /opt/homebrew/include/yaml.h 2>/dev/null)" ] || \
     [ -n "$(ls /usr/local/lib/libyaml.* /opt/homebrew/lib/libyaml.* 2>/dev/null)" ]; }; then
    echo "cmake, libyaml and ninja found."
else
    if which -s brew; then
        echo "Attempting to install the following with Homebrew: cmake, ninja, libyaml"
        brew install cmake ninja libyaml
    else
        echo "Dependencies not found. Make sure these are installed: cmake, ninja, libyaml"
    fi
fi

DUMMY=$( xcode-select -p 2>&1 )
if [ "$?" -eq 0 ]; then
    echo "Xcode found."
else
    echo "Xcode not found."
    exit 1
fi

if which -s sccache; then
    echo "sccache found, unsetting CC & CXX"
    unset CC
    unset CXX
else
    echo "sccache not found, skipping CC/CXX unset"
fi


# Deps download and checks
DUMMY=$(ls $DEPS 2>&1)

if [ "$?" -eq 0 ]; then
    echo "Deps directory found."
else
    echo "Deps directory not found. Creating one..."
    mkdir $DEPS

    if [ "$?" -eq 0 ]; then
        echo "Deps directory successfully created."
    else
        echo "Couldn't create Deps directory. Check permissions and try again."
        exit 1
    fi
fi

DUMMY=$(ls $ASEPRITE/ 2>&1)
if [ "$?" -eq 0 ]; then
    echo "Aseprite was found."
else
    echo "Aseprite not found. Downloading..."

    rm $TMPDIR/asesrc.zip
    curl $ASEZIP -L -o $TMPDIR/asesrc.zip
    mkdir $ASEPRITE
    tar -xf $TMPDIR/asesrc.zip -C $ASEPRITE

    if [ "$?" -eq 0 ]; then
        echo "Aseprite successfully downloaded and extracted."
    else
        echo "Aseprite failed to download and extract. Check internet connection and try again later."
        exit 1
    fi
fi

DUMMY=$(ls $SKIA/ 2>&1)
if [ "$?" -eq 0 ]; then
    echo "Skia found."
else
    echo "Skia not found. Downloading..."

    rm $TMPDIR/skia.zip
    curl $SKIAZIP -L -o $TMPDIR/skia.zip
    mkdir $SKIA
    tar -xf $TMPDIR/skia.zip -C $SKIA

    if [ "$?" -eq 0 ]; then
        echo "Skia successfully downloaded and extracted."
    else
        echo "Skia failed to download and extract. Check internet connection and try again later."
        exit 1
    fi
fi

# Cannot use sccache for the build.
if [[ "$CC" == *sccache* || "$CXX" == *sccache* ]]; then
    rm -rf deps/aseprite/build
    echo "Cannot compile Aseprite with sccache."
    exit 1
fi

# Begin compiling...
echo "Beginning compilation for Apple Silicon (tested on M1)..."
cd $ASEPRITE
mkdir build
cd build
cmake \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DCMAKE_OSX_ARCHITECTURES=arm64 \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0 \
    -DCMAKE_OSX_SYSROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk \
    -DLAF_BACKEND=skia \
    -DSKIA_DIR=$SKIA \
    -DSKIA_LIBRARY_DIR=$SKIA/out/Release-arm64 \
    -DSKIA_LIBRARY=$SKIA/out/Release-arm64/libskia.a \
    -DPNG_ARM_NEON:STRING=on \
    -G Ninja \
    ..

if [ "$?" -eq 0 ]; then
    ninja aseprite

    if [ "$?" -eq 0 ]; then
        echo "Build complete! Packaging into an app..."

        cd $ROOT && mkdir -p Aseprite.app/Contents
        cp -r ./Aseprite.app.template/. ./Aseprite.app/Contents/
        mkdir -p ./Aseprite.app/Contents/MacOS
        mkdir -p ./Aseprite.app/Contents/Resources
        cp $ASEPRITE/build/bin/aseprite ./Aseprite.app/Contents/MacOS/
        cp -r $ASEPRITE/build/bin/data ./Aseprite.app/Contents/Resources/
        sed -i "" "s/1.2.34.1/$LATEST_RELEASE/" ./Aseprite.app/Contents/Info.plist

        xattr -r -d com.apple.quarantine ./Aseprite.app

        echo "Aseprite.app is ready. You can find it in the Aseprite directory."
        echo "NOTE: For recompilation convenience, the source and other dependencies are stored in the deps/ directory. You may delete this in order to compile a newer version."
        exit 0
    else
        echo "Failed to compile. Check Skia version and try again later..."
        exit 1
    fi

else
    echo "Configuring cmake failed. Check if all code is downloaded properly. Exiting..."
    exit 1
fi
