# IREE for Apple Platforms

This project builds the IREE compiler into a command-line tool for macOS and the IREE runtime into an XCFramework that can be dragged and dropped into Xcode projects. The XCFramework enables the development of apps for Apple devices and computers that do deep learning inference and training.

## Usage

Git-clone this repo and the [IREE repo](https://github.com/openxla/iree/). Make sure that they are in the same directory.  For example:

```
~/work
├── iree-for-apple-platforms
└── iree
```

Run `~/work/iree-for-apple-platforms/build.sh` to build 
1. the IREE runtime into `~/iree-for-apple-platforms/build/runtime/iree.xcframework`, and 
1. the IREE compiler and debugging tools into `~/iree-for-apple-platforms/build/compiler/install/bin/`.

Run `build.sh -f` to force rebuild the IREE runtime XCFramework.

Run `build.sh -r` to force rebuild the IREE compiler and runtime.

Run `build.sh -m` to enable the Metal GPU support.

## Supported Apple Platforms

Apple devices run various operating systems, and each kind of device may have more than one CPU architecture.  The built `iree.xcframework` supports the following platforms:

1. macOS - x86_64 and arm64
1. iOS   - arm64 and arm64e
1. tvOS  - arm64
1. watchOS - arm64

## What Does This Project Do

The IREE runtime is built by `build.sh` into a `libiree.a` library for each OS-CPU combo.

For all CPU architectures of an OS, `build.sh` combines the `libiree.a` files into a single FAT `libiree.a` file.

For each OS, `build.sh` puts the IREE runtime header files and this FAT `libiree.a` into a [framework](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPFrameworks/Concepts/WhatAreFrameworks.html), which is a bundle, or a directory structure, on the filesystem.

For all frameworks for all of the above operating systems, `build.sh` combines the framework bundles into an XCFramework (https://developer.apple.com/documentation/xcode/creating-a-multi-platform-binary-framework-bundle).
