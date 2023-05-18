#!/bin/bash

# This script builds the GPT-2 implementation in iree-org/iree-jax
# into a VMFB of Metal GPU kernels.

# exit when any command fails
set -e

SCRIPT_DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
PROJECT_DIR=$(realpath "$SCRIPT_DIR"/../..)
WORK_DIR=$(realpath "$PROJECT_DIR"/..)
IREE_JAX_DIR=$WORK_DIR/iree-jax

if [[ ! -d $IREE_JAX_DIR ]]; then
    echo "Git-cloning iree-org/iree-jax to $IREE_JAX_DIR ..."
    git clone --recursive https://github.com/iree-org/iree-jax "$IREE_JAX_DIR"
fi

echo "Downloading GPT-2 model files ..."
"$IREE_JAX_DIR"/models/gpt2/setup.sh

echo "Setup environment variables ..."
# shellcheck source=/dev/null
source "$PROJECT_DIR"/install.sh
# test if iree.compiler and iree.runtime are successfully installed
IMPORT_TEST="import iree.compiler, iree.runtime"
if python3 -c "$IMPORT_TEST"; then
    echo "$IMPORT_TEST works"
else
    echo "error: $IMPORT_TEST does not work"
    exit 2
fi

export PYTHONPATH=$PYTHONPATH:"$IREE_JAX_DIR"
echo "Set PYTHONPATH to $PYTHONPATH"

echo "Export MLIR of GPT-2 ..."
python3 "$IREE_JAX_DIR"/models/gpt2/export.py --batch_size=1 --no_compile

echo "Build GPT-2 for Metal GPU ..."
iree-compile \
  --iree-input-type=mhlo \
  --iree-hal-target-backends=metal \
  --iree-metal-compile-to-metallib=false \
  /tmp/gpt2.mlir \
  -o /tmp/gpt2-metal.vmfb
