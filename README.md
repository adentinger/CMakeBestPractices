# CMake Dev/CI/CD environment

CMake project that leverages "modern CMake" to produce a build system and dev environement that would be suitable for a fairly scalable open-source or closed-source project.

This is based off of resources such as these (in decreasing order of importance):
- [C++Now 2017 - "Effective CMake"](https://youtu.be/bsXLMQ6WgIk)
- [CppCon 2018 - "Don't Package Your Libraries, Write Packagable Libraries! (Part 1)"](https://youtu.be/sBP17HQAQjk)
- [CppCon 2019 - "Don't Package Your Libraries, Write Packagable Libraries! (Part 2)"](https://youtu.be/_5weX5mx8hc)
- [CppCon 2021 - "Modern CMake Modules"](https://youtu.be/IZXNsim9TWI)

## Prerequisites

### Quick-and-dirty

- Ubuntu:

```bash
# Assumes cmake's version is >= to version required by this project. If not
# the case, see below.
sudo apt install build-essential ninja-build cmake
# Optional dependencies
sudo apt install clang-format-15 clang-tidy-15
```

### Actual dependencies

- CMake >= 3.25. If such a version is not available on your system, you can [download/install it here](https://cmake.org/download/).
- A generator supported by CMake (such as `ninja` or `make`).
- (Optional) `clang-tidy` and `clang-format` version >= 15. Needed by the `static-dev` and `shared-dev` configure presets.

## How to use

### The quick-and-dirty way

```sh
# Requires the generator executable (e.g. 'ninja') to be in the PATH.
CMAKE_GENERATOR=<Specify Generator> \
./build-and-run.sh
```

For example:

```sh
CMAKE_GENERATOR=Ninja \
./build-and-run.sh
```

The `build-and-run.sh` script has environment variables that control it; run `./build-and-run.sh --dry-run` for a list. For example:

```sh
# The "*-dev" presets require clang-tidy and clang-format available in PATH.
# To get a list of presets for each project, cd to that project and run
# "cmake --list-presets"
#
# Note environment variables are passed as-is to CMake, so you can specify
# environment variables to be used by CMake such as CMAKE_GENERATOR or VERBOSE.
# See: https://cmake.org/cmake/help/latest/manual/cmake-env-variables.7.html
PRJ1_CONFIGURE_PRESET=shared-dev \
PRJ2_CONFIGURE_PRESET=static-dev \
PRJ1_CONFIG=Debug \
CMAKE_GENERATOR="Visual Studio 17 2022" \
VERBOSE=1 \
./build-and-run.sh
```

### The robust way

Run `./build-and-run --dry-run` to get the cmake commands that would be run in a non-dry run.

This would be useful to someone integrating this repo's CMake projects/libraries in their own project. This way they can integrate the commands in their own build system in the normal CMake way, rather than being forced to go out of their way to call the `build-and-run.sh` script.

This would also be useful to a package maintainer to integrate the CMake projects' librairies in their own package manager, since they want to take hold of the build and dependencies themselves.

