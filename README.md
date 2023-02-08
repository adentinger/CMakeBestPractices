# CMake Import Tests

Tests of making libraries and importing them in other CMake projects or
targets.

## How to use

Requires CMake v3.25. If it such a version is not available on your system, you can download it and then point the `compile-and-run.sh` script to the directory where .

```sh
CMAKE_GENERATOR=<Specify Generator> \
	CMAKE_BUILD_TYPE=<Specify build type> \
    CMAKE_DIR=<path to CMake's dir if cmake is not in PATH; the CMake executable is "${CMAKE_DIR}/bin/cmake"> \
    ./compile-and-run.sh
```

For example:

```sh
CMAKE_GENERATOR=Ninja \
	CMAKE_BUILD_TYPE=Release \
    ./compile-and-run.sh
```

### Multi-config generators

Note that, at the moment, multi-config generators (e.g. `Visual Studio *`, `XCode`, ...) do not work with `compile-and-run.sh`. If you want to compile this project using a multi-config generator, you will have to figure out and specify the CMake flags manually without using `compile-and-run.sh`. To do that, try a single-config generator (e.g. Ninja) and look at the cache variables in `cmake-gui` or `ccmake`, or just look at the generated `CMakeCache.txt` directly.

This is because one of this project's goals is to try out new and shiny CMake stuff, so `compile-and-run.sh` uses CMake's `CMakePresets.json` file to specify configure, build and test presets. In a normal context, this file is meant to be used interactively, not through a script, but, well, we really want to try out the new and shiny, so we want to build through that.

Unfortunately, externally via an environment variable, we can't find a way to provide the config (Release/Debug/RelWithDebInfo/...) to build, test, and install, except maybe if we used CMake's [CMAKE_DEFAULT_BUILD_TYPE](https://cmake.org/cmake/help/latest/variable/CMAKE_DEFAULT_BUILD_TYPE.html#variable:CMAKE_DEFAULT_BUILD_TYPE) cache variable in the presets file and get that variable's value through an environement variable. However, even if we did that, it would only work with the `Ninja Multi-Config` generator because that cache variable is only used by that specific generator. So multi-config generators don't work with the `compile-and-run.sh` script right now.

