cmake --workflow --preset ninja-release

# cd "$HOME/Git/foo/lib1" && rm -rf build include/ bin lib cmake && mkdir build && cd build/ && cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$(realpath "$(pwd)/..")" -DCMAKE_EXPORT_COMPILE_COMMANDS=On -DBUILD_SHARED_LIBS=Off .. && cmake --build . && cmake --install .

