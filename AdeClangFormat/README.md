# AdeClangFormat

This CMake module is a simple and pragmatic helper for running `clang-format` in the context of a CMake build:

```cmake
find_package(AdeClangFormat 1.0 CONFIG REQUIRED)
ade_clang_format_targets(TARGETS
  target1
  target2)
```

This introduces two main new targets (which you can run with `cmake --build <binary-dir> --target <target>`):
- `formatfix`: Runs `clang-format` on the sources of all specified targets, asking `clang-format` to fix them.
- `formatcheck`: Runs `clang-format` on the sources of all specified targets without actually modifying the sources. Returns nonzero (failure) if `clang-format` finds formatting errors.

By default, building the specified target(s) also runs `clang-format` to check that target's sources (but that can be turned off; see below). Useful to enforce formatting compliance, such as in a CI build.

The `clang-format` command to run can be specified via the CMake cache variable `ADE_CLANG_FORMAT` (similarly to CMake's `CMAKE_CLANG_TIDY` cache variable):

```bash
cmake -DADE_CLANG_FORMAT:STRING='clang-format;--style=file:.clang-format' <other-flags>
```

## Full usage

