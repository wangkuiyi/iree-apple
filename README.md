# IREE for Apple Platforms

Run `build.sh` in this project to

1. build the IREE compiler and other tools into command-line programs for macOS, and
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

1. the IREE runtime into `~/w/iree-for-apple-platforms/build/runtime/iree.xcframework`, and
1. the IREE compiler, runtime, and Python binding for macOS in `~/w/iree-for-apple-platforms/build/compiler`.

Run `build.sh -f` to force rebuild the IREE runtime XCFramework.

Run `build.sh -r` to force rebuild the IREE compiler and runtime.

Run `build.sh -m` to enable the Metal GPU support. As of Apr 20, 2023, the Metal GPU backend is in https://github.com/antiagainst/iree/tree/apple-metal-hal. It will be merged into the official repo soon.

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

After the building, run the following command to set the environment variables.

```bash
source ~/work/iree-for-apple-platforms/build/compiler/.env
export PYTHONPATH
export PATH
```

### Build IREE Runtime into iree.xcframework

This step uses the CMakeLists.txt file in this project.  It includes the following steps:

1. The IREE runtime is built by `build.sh` into a `libiree.a` library for each OS-CPU combo.
1. For all CPU architectures of an OS, `build.sh` combines the `libiree.a` files into a single FAT `libiree.a` file.
1. For each OS, `build.sh` puts the IREE runtime header files and this FAT `libiree.a` into a [framework](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPFrameworks/Concepts/WhatAreFrameworks.html), which is a bundle, or a directory structure, on the filesystem.
1. For all frameworks for all of the above operating systems, `build.sh` combines the framework bundles into an XCFramework (https://developer.apple.com/documentation/xcode/creating-a-multi-platform-binary-framework-bundle).
