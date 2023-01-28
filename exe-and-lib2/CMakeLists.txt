cmake_minimum_required(VERSION 3.23)

project(exe
  VERSION 1.0
  LANGUAGES CXX)

# Reason to do that even if we don't have tests:
# https://youtu.be/IZXNsim9TWI?t=2426
enable_testing()

add_subdirectory(lib2)
add_subdirectory(exe)

