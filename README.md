# espressif-mcuboot-docker

Required files for building a `Dockerfile` which contains everything necessary to build [mcuboot] for Espressif chips, using [esp-hal-3rdparty] as the HAL layer.

This is all quite rudimentary still, and there's definitely room for improvement, but it gets the job done for now.

[mcuboot]: https://github.com/mcu-tools/mcuboot
[esp-hal-3rdparty]: https://github.com/espressif/esp-hal-3rdparty

## Usage

First, build the docker image; you may optionally tag the image, as demonstrated below:

```shell
docker build -t espressif-mcuboot .
```

Which the docker image built, we can spin up a container and enter the build environment. We will mount a local volume so that we can transfer the compiled binaries back to the host system:

```shell
docker run --rm -it -v /local/path/to/mount:/build espressif-mcuboot /bin/bash
```

From within the running container, we can invoke the build script. Various environment variables can be set in order to configure the build, see `bootloader.conf` for more information.

```shell
TARGET=esp32c3 ./build.sh
# Copy the built binaries out of the container and back into your host system:
cp -r /mcuboot/boot/espressif/build/mcuboot* /build/
```
