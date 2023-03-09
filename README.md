# CMake Best Practices Tests

CMake project that leverages "modern CMake" to produce a build system and dev environement that would be suitable for a fairly scalable open-source or closed-source project.

This is based off of resources such as these (in order of importance):
- [C++Now 2017 - "Effective CMake"](https://youtu.be/bsXLMQ6WgIk)
- [CppCon 2018 - "Don't Package Your Libraries, Write Packagable Libraries! (Part 1)"](https://youtu.be/sBP17HQAQjk)
- [CppCon 2019 - "Don't Package Your Libraries, Write Packagable Libraries! (Part 2)"](https://youtu.be/_5weX5mx8hc)
- [CppCon 2021 - "Modern CMake Modules"](https://youtu.be/IZXNsim9TWI)

## How to use

Requires CMake >= 3.25. If it such a version is not available on your system, you can [download/install it here](https://cmake.org/download/). If it is not installed/extracted to a location in the PATH, you can point the `compile-and-run.sh` script to the directory where you installed/extracted it using the `CMAKE_DIR` variable that the `compile-and-run.sh` script uses.

In general, here is how to use this repo:

```sh
CMAKE_GENERATOR=<Specify Generator> \
CMAKE_BUILD_TYPE=<Specify build type> \
CMAKE_DIR=<path to CMake's dir if cmake is not in PATH; the CMake executable is "${CMAKE_DIR}/bin/cmake"> \
PRJ1_WORKFLOW=<Specify workflow preset to use non-default value> \
PRJ2_WORKFLOW=<Specify workflow preset to use non-default value> \
./compile-and-run.sh
```

For example:

```sh
# The "*-dev" workflows require clang-tidy and clang-format available in PATH.
CMAKE_GENERATOR=Ninja \
CMAKE_BUILD_TYPE=Release \
PRJ1_WORKFLOW=shared-dev \
./compile-and-run.sh
```

### Multi-config generators

Note that, at the moment, multi-config generators (e.g. `Visual Studio *`, `XCode`, ...) do not work with `compile-and-run.sh`. If you want to compile this project using a multi-config generator, you will have to figure out and specify the CMake flags manually without using `compile-and-run.sh`. To do that, have a look at this project's CI script (`.github/workflows/cmake.yml`), or try a single-config generator (e.g. Ninja) and look at the cache variables with `cmake-gui` or `ccmake` or just by looking at the generated `CMakeCache.txt` directly.

This is because one of this project's goals is to try out new and shiny CMake stuff, so `compile-and-run.sh` uses CMake's `CMakePresets.json` file to specify configure, build and test presets. In a normal context, `CMakePresets.json` is meant to be used interactively, not through a script, but, well, we really want to try out the new and shiny, so we want to build through that.

Unfortunately, externally via an environment variable, we can't find a way to provide the config (Release/Debug/RelWithDebInfo/...) to build, test, and install, except maybe if we used CMake's [CMAKE_DEFAULT_BUILD_TYPE](https://cmake.org/cmake/help/latest/variable/CMAKE_DEFAULT_BUILD_TYPE.html#variable:CMAKE_DEFAULT_BUILD_TYPE) cache variable in the presets file and got that variable's value through an environement variable. However, even if we did that, it would only work with the `Ninja Multi-Config` generator because that cache variable is only used by that specific generator. So multi-config generators don't work with the `compile-and-run.sh` script right now. The only reliable way to specify which config to use to build, test and install is to specify it in on the commandline (e.g. using the `--config` flag), which is currently incompatible with CMake's `--workflow` flag that is used to use the `CMakePresets.json`'s `"workflowPresets"` to configure, build, and test the CMake projects.

