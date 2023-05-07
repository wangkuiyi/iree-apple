# Compile GPT-2 for On-Device Fine-Tuning Using Metal GPUs

In the repo [`iree-org/iree-jax`](https://github.com/iree-org/iree-jax/tree/main/models/gpt2), there is a JAX-implementation of GPT-2. This implementation includes functions to fine-tune the GPT-2 model and functions for inference with memory. We can compile this JAX program a vmfb file using the IREE compiler, so we can run it on iOS and macOS.  We will use a feature branch of IREE that supports the Metal GPU.

## Build IREE with Metal GPU Support

Following steps in [`README.md`](/README.md) to build the IREE compiler and runtime for macOS, and the runtime as an XCFramework for macOS and iOS.

**04/26/2023** Please be aware that we will need to build this [feature branch](https://github.com/antiagainst/iree/tree/metal-hal-pr) before it lands to the main branch.

### Fetch the Source Code

If you have git-cloned IREE to `~/work/iree`, run the following commands to switch over to the above feature branch.

```bash
cd ~/work/iree
git remote add lei https://github.com/antiagainst/iree
git fetch lei
git checkout metal-hal-pr
git submodule update
```

Or, you can clone the above feature branch.

```bash
cd ~/work
git clone https://github.com/antiagainst/iree -b metal-hal-pr
```

### Build IREE from Source Code

Please remember to use `-m` to enable the Metal GPU support.

```bash
~/work/iree-for-apple-platforms/build.sh -m
```

If you have built IREE without the Metal GPU support, you might want to save it for futher use by renaming it.

```bash
cd ~/work/iree-for-apple-platform
mv build build.old
./build.sh -m
```

Or, if you want to overwrite it, you can use the `-r` option.

```bash
~/work/iree-for-apple-platforms/build.sh -m -r
```

The building process will last for about an hour on M1 MacBook Pro.  After the build, run the following command to set the environment variables.

```bash
source ~/work/iree-for-apple-platforms/install.sh
```

### Verify Compiler and Runtime Work with Metal GPU

To check if the IREE compiler supports generating Metal GPU code, please run the following command.

```bash
iree-compile  --iree-hal-list-target-backends
```

You should read something like the following.

```
metal
metal-spirv
```

To check if the IREE runtime supports Metal GPU, please run the following command on a Mac with M1 or M2 CPU.

```bash
iree-run-module --dump_devices
```

You should read something like the following.

```
# ===----------------------------------------------------------------------===
# --device=metal://000000010000095a
#   Apple M1 Max
# ===----------------------------------------------------------------------===
```

### Compile the Fine-tuning Program of GPT-2

The first step is to convert the JAX program into MLIR using `iree.jax`.  The second step is to compile the MLIR file into a vmfb file using IREE.

### From JAX to MLIR

Git clone the source code.

```bash
cd ~/work
git clone https://github.com/iree-org/iree-jax
```

Download model files to `~/work/iree-jax/models/gpt2/assets`.

```bash
iree-jax/models/gpt2/setup.sh
```

Generate the MLIR file `/tmp/gpt2.mlir`.

```bash
python iree-jax/models/gpt2/export.py
```

### From MLIR to VMFB

```bash
iree-compile \
  --iree-input-type=mhlo \
  --iree-hal-target-backends=metal \
  --iree-metal-compile-to-metallib=false \
  /tmp/gpt2.mlir \
  -o /tmp/gpt2-metal.vmfb
```
