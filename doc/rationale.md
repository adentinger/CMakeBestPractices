# Rationale & features of this repo's environment

We've all been there: we've seen a C/C++ project grow to a point where the overly simple initial build system could no longer cope with gradually increasing requirements, forcing someone to go and spend a long time digging through arcane build magic, introducing bugs and linking errors down the line, and completely changing the build workflow. Something along the lines of:

- "Up until now, we only had static libraries, but now we want to also support shared libraries, which are completely different between Windows and *nix."
- "We learned about tools like C/C++ package managers and static analyzers a while ago, but we don't know how they could fit in our workflow."
- "We want to support BYOD, but our build system is full of hardcoded paths and flags and only works with `apt-get`, and only on Ubuntu 22.04, so the setup is a tad sensitive."

This repo mimics a superproject (i.e., a project that contains multiple sub-projects) composed of two CMake sub-projects that support a number of useful features out of the box. It is highly (overly?) documented. At the moment, this repo is best used either as a loose reference point, or as a rough starting point for a CMake C/C++ project or superproject that will grow over time.

## Description of environment

This repo mimics a superproject (i.e., a project that contains multiple sub-projects) composed of two CMake sub-projects:

- `prj1`: A CMake project containing a single library, `lib1`.
- `prj2`: A CMake project containing a library, `lib2`, which depends on `lib1`, and an executable, `exe`, which depends on both `lib1` and `lib2`.

The libraries' and executable's contents are mostly irrelevant; just silly Fibonacci shenanigans!

## Features of environment

The environment:
- Works identically across all three main platforms: Linux, MacOS, and Windows.
- Works with both single-config generators (e.g. `Ninja`, `Unix Makefile`) and multi-config generators (e.g. `Ninja Multi-Config`, `Visual Studio 17 2022`).
- Leverages [CMake config-file packages](https://cmake.org/cmake/help/latest/manual/cmake-packages.7.html#config-file-packages) to provide dependency information to library consumers, meaning any include directory, library to be linked against transitively, build flag, etc., is automatically propagated to library consumers when invoking `target_link_libraries()`.
- Ensures header include paths are the same both when building the library that owns them, and when building other libraries/executables that depend on it. For example, `#include "lib1/hdr.h"` will work inside `lib1`'s source, and inside `lib2`'s and `exe`'s sources.
- Supports building the libraries either as static or as shared libraries, except that:
    1. With shared libraries, both CMake projects are required to be installed in the same directory[^shared-libs-install]
	2. When `lib1` is built as a static library and `lib2` is built as a shared library, on Linux and MacOS `lib1` needs to be built with [`POSITION_INDEPENDENT_CODE`](https://cmake.org/cmake/help/latest/prop_tgt/POSITION_INDEPENDENT_CODE.html).
- Supports unit tests of the source code of executables, except for the code inside `main.cpp`, as well as unit tests of symbols of shared libraries that are not exported.
- Produces relocatable installation trees, meaning the created install directory(ies) may be copied elsewhere, including on another machine running the same platform.
- Supports the creation of installation packages with CMake's `cpack` (e.g. WIX installers, binary tarballs, `.deb`/`.rpm` packages, etc.)
- Enforces static analysis checks with [`clang-tidy`](https://clang.llvm.org/extra/clang-tidy) and code formatting with [`git-clang-format`](https://clang.llvm.org/docs/ClangFormat.html#git-integration) during the CI build, without requiring these tools to be installed and setup by a contributor in their local tree.
- Uses the [vcpkg](https://vcpkg.io/en/) package manager to easily obtain the dependencies of the CMake projects, rather than directly having each dependency as a submodule and having to figure out how to build them.
	- Both CMake builds share the same `vcpkg` submodule to allow a single dependency installation to be shared, and have an option to allow a developer to specify an existing `vcpkg` directory elsewhere on the system instead for even further sharing, such as in the integration inside a larger superproject.
- Contains a CI build that leverages the same environement as the developer environment, including the static analysis and formatting checks. This is currently done using GitHub Actions (see the `.github/workflows` directory inside this repo), but because much of the logic is handled by CMake, this could be translated to another CI/CD pipeline without too much effort.

[^shared-libs-install]: Shared libraries work quite differently across operating systems. A reliable way of setting them up in a platform-indedpendent fashion is to ensure that all projects are installed to the same location.
  For example, on DLL platforms (such as non-Cygwin Windows), the `.dll` files generally need to be placed in the same directory as the executable that loads them (even indirectly through other DLLs), whereas on Linux and MacOS, the executable usually specifies the paths to serach for its shared libraries via its `RPATH`, and, in turn, each shared library specifies the paths to serach for its own shared libraries via its own `RPATH`.
  These behaviours also impose a few restrictions on Windows when needing to run executables directly inside CMake's build tree, such as in the case of unit test executables. This is handled by copying the DLLs that the executable depends upon into its corresponding CMake binary directory.

## Build use-cases

Additionally to the above, the environment considers multiple build use-cases:

1. Onboarding and irregular contributors: In these contexts, the developer does not want to setup the full development environment; they are merely looking to quickly build the project to try it out, or wish to make a simple contribution without worrying about the details of code formatting/static-analysis of the project's contribution policy. This should generally be the simplest build that should require as few build flags and dependencies to be specified and installed as possible. Nonetheless, a contribution made by an irregular contributor should still go through the static analysis and formatting checks, which is something enforced by the CI build. This is the use-case behind the `build-and-run.sh` script (without the `--dry-run` flag).

2. Regular contributors and CI build: These want the full environment, and want to ensure that their contributions match the contribution policy, without having to constantly issue commits and wait for the CI build to catch errors, or having to issue a large 'fix' commit that adds noise to the source history. This is the use-case behind the `*-dev` presets of the `CMakePresets.json` files.

3. Developers integrating the project, and package maintainers: They may not know know the project well, if at all, but want to integrate it into an existing build of a larger project, or inside a package manager (pacman, apt, vcpkg, pip3, ...) while ensuring that the build remains simple and consistent over version upgrades, despite the disparity of build environments. This is the use-case behind the `build-and-run.sh` script with the `--dry-run` flag. They have a usual way of building dependencies and therefore do not want to go out of their way to call a platform-dependent build script. They may be fine, however, with using something like the well-known `CMakePresets.json` file for the configure step if the project clearly states that this a well-behaved way to build it.

NOTE: Because this is a superproject, the orchestration of both CMake builds is done by another tool, in this case the `build-and-run.sh` script. In a single-build situation, that script would be undesirable and should be replaced by a single `CMakePresets.json` file. In that case, the explanation of the commands to run inside the repo's `README.md` file should include all the build commands; usually something along the lines of:

```bash
cd repo-dir && \
cmake -S . -B build --preset <configure-preset-name> && \
cmake --build build -j10 && \
ctest --test-dir build -j10 && \
cmake --install build # And/or a cpack command
```

### Source tree

The environment follows an opinionated source tree hierarchy. The sources of both libraries, as well as the executable, have the same structure:

```
<lib or exe name>
├── CMakeLists.txt  # Main CMakeLists.txt for the library/executable
├── include
│   └── <lib name>
│       └── <public headers>  # Headers needed to build the library and needed
│                             # by the consumers of the library
├── src
│   ├── <c/cpp files>         # Source files of the library (could also be
│   │                         # C++20 modules perhaps?)
│   └── <lib or exe name>
│       └── private
│           └── <private headers>  # Headers needed to build the library, but
│                                  # which aren't installed. May be especially
│                                  # important in closed-source projects.
└── test
    ├── CMakeLists.txt     # For tests setup
    └── src
        └── <c/cpp files>  # Source files and headers for the test executable
```
