# CMake Dev/CI/CD environment

A CMake superproject that leverages "modern CMake" to produce a build system and dev/CI/CD environement that would be suitable for a fairly scalable open-source or closed-source project.

**For a thorough description of the rationale and features of this repo's environment, see [this file](doc/rationale.md).**

## Building

### The easy way

*NOTE: This section corresponds to how a real project would explain to an irregular contributor, or someone trying out the project, how to build it. It should probably be augmented to include a link to a webpage, wiki, tutorial, video, or other documentation that explains how to use the project once built.*

Here's how to get the project's dependencies:

- Ubuntu:

```bash
# Assumes cmake's version is >= to version required by this project. If not
# the case, see below.
sudo apt install build-essential ninja-build cmake
# Optional dependencies --generally for regular contributors of the project
sudo apt install clang-format-16 clang-tidy-16
```

- Actual dependencies:
    - CMake >= 3.26. If such a version is not available on your system, you can [download/install it here](https://cmake.org/download/).
    - A generator supported by CMake (such as `ninja` or `make`).
    - (Optional) `clang-tidy` and `clang-format` version >= 16. Only needed by the `static-dev` and `shared-dev` configure presets.

Here's how to build the project:

```sh
# Requires the generator executable (e.g. 'ninja') to be in the PATH.
# Note that environment variables are passed as-is to CMake, so you can specify
# environment variables to be used by CMake, such as CMAKE_GENERATOR or VERBOSE.
# See: https://cmake.org/cmake/help/latest/manual/cmake-env-variables.7.html
CMAKE_GENERATOR=<Specify Generator> \
./build-and-run.sh
```

For example:

```sh
CMAKE_GENERATOR=Ninja \
./build-and-run.sh
```

The built binaries will then be available under `install/`.

### The robust way

*NOTE: This section corresponds to how a real project would explain how to integrate the build of that project into a larger build, such as a developer integrating the project into a larger one, or a package maintiner adding the project to a package manager (pacman, apt, vcpkg, pip3, ...).*

Run `./build-and-run --dry-run` to get the cmake commands that would be run in a non-dry run, as well as a list of environment variables that control the behavior of the build. For example:

```sh
# The "*-dev" presets require clang-tidy and clang-format available in PATH.
# To get a list of presets for each project, cd to that project and run
# "cmake --list-presets".
#
# Note that environment variables are passed as-is to CMake, so you can specify
# environment variables to be used by CMake, such as CMAKE_GENERATOR or VERBOSE.
# See: https://cmake.org/cmake/help/latest/manual/cmake-env-variables.7.html
PRJ1_CONFIGURE_PRESET=shared-dev \
PRJ2_CONFIGURE_PRESET=static-dev \
PRJ1_CONFIG=Debug \
CMAKE_GENERATOR="Visual Studio 17 2022" \
VERBOSE=1 \
./build-and-run.sh --dry-run
```
