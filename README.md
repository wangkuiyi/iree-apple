# IREE for Apple Platforms

Run `build.sh` in this project to

1. build the IREE compiler, runtime, and Python binding for macOS, and
1. build the IREE runtime into an [XCFramework bundle](https://developer.apple.com/documentation/xcode/creating-a-multi-platform-binary-framework-bundle) that supports macOS, iOS, and iOS simulator.

**Do not run cmake with the CMakeLists.txt file unless you know how to set the many options.**

## Prerequisite

1. Mac
1. Xcode, which includes
   1. python3 and pip3, and
   1. clang
1. [Homebrew](https://brew.sh/)
1. CMake and Ninja
   ```bash
   brew install cmake ninja
   ```

## Usage

Git-clone this repo and the [IREE repo](https://github.com/openxla/iree/). Make sure that they are in the same directory.  For example:

```
~/work
├── iree-for-apple-platforms
└── iree
```

Run `~/work/iree-for-apple-platforms/build.sh` to build

1. the IREE runtime into `~/work/iree-for-apple-platforms/build/runtime/iree.xcframework`, and
1. the IREE compiler, runtime, and Python binding for macOS in `~/work/iree-for-apple-platforms/build/compiler`.

Run `build.sh -f` to force rebuild the IREE runtime XCFramework.

Run `build.sh -r` to force rebuild the IREE compiler and runtime.

Run `build.sh -m` to enable the Metal GPU support. As of Apr 20, 2023, the Metal GPU backend is in https://github.com/antiagainst/iree/tree/apple-metal-hal. It will be merged into the official repo soon.

## Steps-by-step Guide

Clone this project.

```bash
mkdir ~/work/
cd ~/work
git clone <URL to this project>
```

Clone IREE.

```bash
cd ~/work
git clone --recursive https://github.com/openxla/iree
```

If you want Metal GPU support, you will need to clone https://github.com/antiagainst/ and use the branch `apple-metal-hal`.

```bash
cd ~/work/iree
git remote add lei https://github.com/antiagainst/iree
git fetch lei
git checkout metal-hal-pr
git submodule update
```

Build IREE compiler, runtime, and Python binding for macOS, and IREE runtime into an XCFramework.

```bash
cd ~/work/iree-for-apple-platform
./build.sh
```

Run the following commands to

1. Set `DYLD_LIBRARY_PATH` environment variable to expose the dynamic library of IREE compiler.
1. Set `PATH` environment variable and run `iree-compile`.
1. Set `PYTHONPATH` environment variable to expose Python packages `iree.compiler` and `iree.runtime`.

```bash
source ./install.sh
```

Then, you should be able to run the IREE compiler from the command-line.

```bash
iree-compile -h
```

and you should be able to import `iree.compiler` and `iree.runtime` in Python.

```bash
python3 -c 'import iree.compiler; import iree.runtime'
```

## Supported Apple Platforms

Apple devices run various operating systems, and each kind of device may have more than one CPU architecture.  The built `iree.xcframework` supports the following platforms:

| Apple Platform | CPU architectures |
| -------------- | ----------------- |
| macOS          | x86_64 and arm64  |
| iOS            | arm64 and arm64e  |
| iOS Simulator  | x86_64 and arm64  |

## What Does This Project Do

### Build IREE Compiler, Runtime, and Python Binding for macOS

This step uses the CMakeLists.txt file in the root directory of the IREE project.

### Build IREE Runtime into iree.xcframework

This step uses the CMakeLists.txt file in this project.  It includes the following steps:

1. The IREE runtime is built by `build.sh` into a `libiree.a` library for each OS-CPU combo.
1. For all CPU architectures of an OS, `build.sh` combines the `libiree.a` files into a single FAT `libiree.a` file.
1. For each OS, `build.sh` puts the IREE runtime header files and this FAT `libiree.a` into a [framework bundle](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPFrameworks/Concepts/WhatAreFrameworks.html), which is a bundle, or a directory structure, on the filesystem.
1. For all frameworks for all of the above operating systems, `build.sh` combines the framework bundles into an XCFramework bundle.
