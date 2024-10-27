FROM python:3.13-slim-bookworm

# ¯\_(ツ)_/¯
WORKDIR /

# Install all build dependencies via `apt-get` before we start:
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
 && apt-get install -y build-essential cmake curl gettext git ninja-build \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Download and extract the RISC-V toolchain:
ENV RISCV32_RELEASE="esp-14.2.0_20240906"
ENV RISCV32_TAR_GZ="riscv32-esp-elf-14.2.0_20240906-x86_64-linux-gnu.tar.gz"
RUN curl -L -O https://github.com/espressif/crosstool-NG/releases/download/$RISCV32_RELEASE/$RISCV32_TAR_GZ \
 && tar -xf $RISCV32_TAR_GZ \
 && rm -f $RISCV32_TAR_GZ

# Download and extract the Xtensa toolchain:
ENV XTENSA_RELEASE="esp-14.2.0_20240906"
ENV XTENSA_TAR_GZ="xtensa-esp-elf-14.2.0_20240906-x86_64-linux-gnu.tar.gz"
RUN curl -L -O https://github.com/espressif/crosstool-NG/releases/download/$XTENSA_RELEASE/$XTENSA_TAR_GZ \
 && tar -xf $XTENSA_TAR_GZ \
 && rm -f $XTENSA_TAR_GZ

# Update `$PATH` so that the RISC-V and Xtensa toolchains can be found:
ENV PATH="$PATH:/riscv32-esp-elf/bin"
ENV PATH="$PATH:/xtensa-esp-elf/bin"

# Clone the `esp-hal-3rdparty` repo and check out the appropriate sync branch:
ENV SYNC_BRANCH="sync/release_v5.1.c"
RUN git clone https://github.com/espressif/esp-hal-3rdparty \
 && cd $WORKDIR/esp-hal-3rdparty \
 && git switch $SYNC_BRANCH

# Clone `mcuboot` and install additional build dependencies:
RUN git clone https://github.com/mcu-tools/mcuboot \
 && cd $WORKDIR/mcuboot \
 && python -m pip install --no-cache-dir -r scripts/requirements.txt \
 && python -m pip install --no-cache-dir esptool \
 && git submodule update --init --recursive ext/mbedtls

# Copy in our build script and bootloader configuration file template from
# the host to the container image:
COPY ./build.sh        /build.sh
COPY ./bootloader.conf /bootloader.conf
