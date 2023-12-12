#!/usr/bin/env python3
# SPDX-License-Identifier: MIT
import argparse
import inspect
import os
import re
import subprocess
import sys

from pathlib import Path

MAIN_SCRIPT_DIR: Path = Path(inspect.stack()[-1][1]).parent.resolve()

class Params:
	def __init__(self, namespace: argparse.Namespace) -> None:
		self.dry_run = namespace.dry_run

def parse_args(args: list[str] = None) -> Params:
	parser = argparse.ArgumentParser( \
		prog="build-and-run.py",      \
		description="Superproject orchestrator script.")
	parser.add_argument("-n", "--dry-run",      \
		action="store_true",                    \
		help="show commands that would be run", \
		dest="dry_run")
	namespace = parser.parse_args() if args == None else parser.parse_args(args)
	return Params(namespace)

def run_or_print_cmd(cmd: list[str], params: Params, **kwargs: dict[str, str]):
	"""
	Depending on whether we are in a dry run or not, either calls
	subprocess.run() with given kwargs and returns the returned
	subprocess.CompletedProcess, or simply prints 'cmd' and returns None.
	"""
	if params.dry_run:
		whitespaces = re.compile("\s")
		cmd_escaped = \
			[arg if whitespaces.search(arg) == None else '"{}"'.format(arg) \
				for arg in cmd]
		print('-- Would run: {}'.format(" ".join(cmd_escaped)))
		return None
	else:
		return subprocess.run(cmd, **kwargs)

def set_envvars(params: Params) -> None:
	# The output of AdeClangFormat is the same regardless of the preset and
	# config/build-type, so just always pick the same one.
	os.environ["ADECLANGFORMAT_CONFIG"] = "Release"

	if not "PRJ1_CONFIG" in os.environ:
		print('PRJ1_CONFIG not defined, defaulting to "Release"')
		os.environ["PRJ1_CONFIG"] = "Release"
	if not "PRJ2_CONFIG" in os.environ:
		print('PRJ2_CONFIG not defined, defaulting to "Release"')
		os.environ["PRJ2_CONFIG"] = "Release"
	if not "PRJ1_CONFIGURE_PRESET" in os.environ:
		print('PRJ1_CONFIGURE_PRESET not defined, defaulting to "shared"')
		os.environ["PRJ1_CONFIGURE_PRESET"] = "Release"
	if not "PRJ2_CONFIGURE_PRESET" in os.environ:
		print('PRJ2_CONFIGURE_PRESET not defined, defaulting to "shared"')
		os.environ["PRJ2_CONFIGURE_PRESET"] = "Release"
	if not "CPACK_GENERATORS" in os.environ:
		print("CPACK_GENERATORS not defined, cpack won't be called")
	if not "CMAKE_DIR" in os.environ:
		print('CMAKE_DIR not specified; not using it')
	if not "ADE_CLANG_FORMAT_GIT_REF_COMMIT" in os.environ:
		print('ADE_CLANG_FORMAT_GIT_REF_COMMIT not defined, defaulting to "origin/main"')
		os.environ["ADE_CLANG_FORMAT_GIT_REF_COMMIT"] = "origin/main"
	if not "VCPKG_DIR" in os.environ:
		VCPKG_DIR = "{}/{}".format(MAIN_SCRIPT_DIR, "vcpkg")
		print('VCPKG_DIR not set, setting it to "{}".'.format(VCPKG_DIR))
		os.environ["VCPKG_DIR"] = VCPKG_DIR

class Paths:
	def __init__(self, params: Params, environ: list[str] = os.environ) -> None:
		# Yes, code above just set these envvar, but we really do need *both*
		# this data member and the envvars, since the CMake executable will use
		# these envvars.
		env_cmake_dir = environ.get("CMAKE_DIR")
		cmake_dir_for_concat = env_cmake_dir + "/" if env_cmake_dir != None else ""
		IS_WINDOWS = sys.platform == "win32"
		cmake_exe_path = "{}{}{}".format( \
			cmake_dir_for_concat,         \
			"cmake",                      \
			".exe" if IS_WINDOWS else "")
		ctest_exe_path = "{}{}{}".format( \
			cmake_dir_for_concat,         \
			"ctest",                      \
			".exe" if IS_WINDOWS else "")
		cpack_exe_path = "{}{}{}".format( \
			cmake_dir_for_concat,         \
			"cpack",                      \
			".exe" if IS_WINDOWS else "")

		self.cmake_exe = Path(cmake_exe_path)
		self.ctest_exe = Path(ctest_exe_path)
		self.cpack_exe = Path(cpack_exe_path)
		self.vcpkg_dir = Path(environ["VCPKG_DIR"])

	def __str__(self) -> str:
		return "cmake_exe: {}, ctest_exe: {}, cpack_exe: {}, vcpkg_dir: {}" \
			.format(self.cmake_exe, self.ctest_exe, self.cpack_exe, \
				self.vcpkg_dir)

def check_cmake_version(params: Params, paths: Paths) -> None:
	MIN_MAJOR=3
	MIN_MINOR=19

	output = run_or_print_cmd([str(paths.cmake_exe), "--version"], params, \
		check=True, \
		text=True, \
		stdout=subprocess.PIPE).stdout
	if output != None:
		print("output: {}".format(output))

def run():
	params = parse_args()
	set_envvars(params)
	paths = Paths(params)
	check_cmake_version(params, paths)

if __name__ == "__main__":
	run()
