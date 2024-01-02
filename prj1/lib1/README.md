# libtommath explanation

The version of libtommath in the `src/` directory is [taken from StepMania's source tree](https://github.com/stepmania/stepmania/tree/5_1-new/src/libtommath).

This is an extremely old version of the libtommath library, but unfortunately on Windows with the newer version of libtommath, even when taken from vcpkg, we have linking errors when using the library. libtommath apparently expects dead code elimination optimizations, or something like that, and with MSVC we seem to run into that issue. We don't want to fix this problem right now, so for now we'll just use StepMania's version.
