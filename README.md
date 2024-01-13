# CMake Best Practices

A CMake superproject that leverages "modern CMake" to produce a build system and dev/CI/CD environement that would be suitable for a fairly scalable open-source or closed-source project. It is composed of two CMake projects, `prj1` and `prj2`, with `prj2`'s targets depending on `prj1`'s.

This repo aims at providing a reference point for solving common build system and dev environment concerns and issues. See [the rationale explanations](doc/rationale.md) for more details. It is highly (overly?) documented. While it does contain some unique content (especially pertaining to shared libraries and `clang-format`), this repo is generally guided by the principles and best practices of resources such as these (in decreasing order of importance):
- [C++Now 2017 - "Effective CMake"](https://youtu.be/bsXLMQ6WgIk)
- [CppCon 2018 - "Don't Package Your Libraries, Write Packagable Libraries!"](https://youtu.be/sBP17HQAQjk)
- [CppCon 2019 - "Don't Package Your Libraries, Write Packagable Libraries! (Part 2)"](https://youtu.be/_5weX5mx8hc)
- [CppCon 2021 - "Modern CMake Modules"](https://youtu.be/IZXNsim9TWI)

💡 There's always something to improve and learn in a dev environement; suggestions and contributions welcome!

**For a more thorough description of the rationale and features of this repo's build system and environment, see [this file](doc/rationale.md).**

## Building

### The easy way

*NOTE: This section corresponds to how a real project would explain to an irregular contributor, or someone trying out the project, how to build it. It should probably be augmented to include a link to a webpage, wiki, tutorial, video, or other documentation that explains how to use the project once built.*

Here's how to get the project's dependencies:

- Ubuntu:

```bash
sudo apt update
# Assumes cmake's version is >= to version required by this project. If not
# the case, see below.
sudo apt-get install -y build-essential ninja-build cmake python3
# Needed by vcpkg ports
sudo apt-get install -y curl zip unzip tar autoconf libtool pkg-config nasm bison libgtk-3-dev libglu1-mesa-dev libxmu-dev libxi-dev libgl-dev libudev-dev
# Optional dependencies --generally for regular contributors of the project
sudo apt-get install -y clang-format-16 clang-tidy-16
```

- Actual dependencies:
    - CMake >= 3.26. If such a version is not available on your system, you can [find it here](https://cmake.org/download/).
    - A generator supported by CMake (such as `ninja` or `make`).
    - python3. If such a version is not available with a package manager, [find it here](https://www.python.org/downloads/).
    - (Optional) `clang-tidy` and `clang-format` version >= 16. Only needed by the `*-dev` configure presets.

Here's how to build the project:

```sh
# Requires the generator executable (e.g. 'ninja') to be in the PATH.
# Note that environment variables are passed as-is to CMake, so you can specify
# environment variables to be used by CMake, such as CMAKE_GENERATOR or VERBOSE.
# See: https://cmake.org/cmake/help/latest/manual/cmake-env-variables.7.html
CMAKE_GENERATOR=<Specify Generator> \
python3 superbuild.py
```

For example:

```sh
CMAKE_GENERATOR=Ninja \
python3 superbuild.py
```

The built binaries will then be available under `install/`.

### The robust way

*NOTE: This section corresponds to how a real project would explain how to integrate the build of that project into a larger build, such as a developer integrating the project into a larger one, or a package maintiner adding the project to a package manager (pacman, apt, vcpkg, pip3, ...). Because this is a superproject, the orchestration of both CMake builds is done by another tool, in this case the `superbuild.py` script. Inside a single project however, like in `prj1` or `prj2`, there is no need for such orchestration.*

Run `python3 superbuild.py --dry-run` to get the cmake commands that would be run in a non-dry run, as well as a list of environment variables that control the behavior of the build. For example:

```sh
# The "*-dev" presets require clang-tidy and clang-format available in PATH.
# To get a list of presets for each project, cd to that project and run
# "cmake --list-presets".
#
# Note that environment variables are passed as-is to CMake, so you can specify
# environment variables to be used by CMake, such as CMAKE_GENERATOR or VERBOSE.
# See: https://cmake.org/cmake/help/latest/manual/cmake-env-variables.7.html
PRJ1_CONFIGURE_PRESET=win-shared-dev \
PRJ2_CONFIGURE_PRESET=win-static-dev \
PRJ1_CONFIG=Debug \
CMAKE_GENERATOR="Visual Studio 17 2022" \
VERBOSE=1 \
python3 superbuild.py --dry-run
```
