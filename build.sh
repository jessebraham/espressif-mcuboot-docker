#!/usr/bin/env bash

set -eo pipefail

# -----------------------------------------------------------------------------
# TARGET CONFIGURATION
#
# All exported environment variables can be overriden by the caller, otherwise
# the default values will be used.
#
# Currently only supports using the default layout, i.e. using a primary,
# secondary, and scratch slot.

# Bootloader size:
export BL_SIZE="${BL_SIZE:-0xF000}"
# Flash size:
export FLASH_SIZE="${FLASH_SIZE:-4MB}"

# Application size:
export APP_SIZE="${APP_SIZE:-0x100000}"
# Scratch size:
export SCRATCH_SIZE="${SCRATCH_SIZE:-0x40000}"

# TODO: We can calculate `SECONDARY_ADDR` and `SCRATCH_ADDR` using
#       `PRIMARY_ADDR` and `APP_SIZE` instead.

# Image primary slot address:
export PRIMARY_ADDR="${PRIMARY_ADDR:-0x10000}"
# Image secondary slot address:
export SECONDARY_ADDR="${SECONDARY_ADDR:-0x110000}"
# Scratch address:
export SCRATCH_ADDR="${SCRATCH_ADDR:-0x210000}"

# Chip to target:
export TARGET="${TARGET:-esp32c3}"

# The bootloader offset is *not* user configurable, but depends on which
# target has been specified:
if [ "$TARGET" = "esp32" ] || [ "$TARGET" = "esp32s2" ]; then
  export BL_OFFSET="0x1000"
else
  export BL_OFFSET="0x0000"
fi

# -----------------------------------------------------------------------------
# BUILD

# Our working directory is just the filesystem root, as per the Dockerfile:
WORKDIR="/"

# Generate an mcuboot configuration file from environment variable using our
# template, and replace the default configuration for the specified target:
envsubst \
  < "$WORKDIR/bootloader.conf" \
  > "$WORKDIR/mcuboot/boot/espressif/port/$TARGET/bootloader.conf"

# Finally, we can build the bootloader:

cd $WORKDIR/mcuboot/boot/espressif

cmake \
  -DCMAKE_TOOLCHAIN_FILE="tools/toolchain-$TARGET.cmake" \
  -DMCUBOOT_TARGET="$TARGET" \
  -DESP_HAL_PATH="$WORKDIR/esp-hal-3rdparty" \
  -B build \
  -GNinja

ninja -C build
