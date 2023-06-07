#!/bin/bash

# exit when any command fails
set -e

SCRIPT_DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
IREE_SRC_DIR=$SCRIPT_DIR/../iree
IREE_BUILD_COMPILER_DIR=$SCRIPT_DIR/build/compiler

# Install deps required to build the Python binding.
python3 -m pip install \
	-r "$IREE_SRC_DIR"/runtime/bindings/python/iree/runtime/build_requirements.txt \
	>"$IREE_BUILD_COMPILER_DIR"/build.log 2>&1

cmake -S ~/w/iree \
	-B build/compiler \
	-DIREE_BUILD_TESTS=OFF \
	-DIREE_BUILD_SAMPLES=OFF \
	-DIREE_BUILD_PYTHON_BINDINGS=ON \
	-DIREE_BUILD_TRACY=OFF \
	-DCMAKE_INSTALL_PREFIX=build/compiler/install \
	-G Ninja \
	>"$IREE_BUILD_COMPILER_DIR"/build.log 2>&1

cmake --build "$IREE_BUILD_COMPILER_DIR" --target install \
	>>"$IREE_BUILD_COMPILER_DIR"/build.log 2>&1
