#!/usr/bin/env python3
# SPDX-License-Identifier: MIT
import argparse
import inspect
import os
import re
import shutil
import subprocess
import sys

from pathlib import Path

MAIN_SCRIPT_DIR: Path = Path(inspect.stack()[-1][1]).parent.resolve()

class Params:
	def __init__(self, namespace: argparse.Namespace) -> None:
		self.is_dry_run = namespace.dry_run
		self.run_exe = namespace.run_exe

def parse_args(args: list[str] = None) -> Params:
	parser = argparse.ArgumentParser( \
		prog="superbuild.py",         \
		description="Superproject orchestrator script.")
	parser.add_argument("-n", "--dry-run",      \
		action="store_true",                    \
		help="show commands that would be run", \
		dest="dry_run")
	parser.add_argument("-r", "--run-exe",    \
		action="store_true",                  \
		help="run executable after building", \
		dest="run_exe")
	namespace = parser.parse_args() if args == None else parser.parse_args(args)
	return Params(namespace)

def run_or_print_cmd(params: Params, cmd: list[str], \
					 # Would like to use "check: bool | None" but GitHub's
					 # Python isn't recent enough for that.
					 check = True, **kwargs: dict[str, str]):
	"""
	Depending on whether we are in a dry run or not, either calls
	subprocess.run() with given kwargs and returns the returned
	subprocess.CompletedProcess, or simply prints 'cmd' and returns None.

	If 'check' is True (default), then sets check=True in the call to
	subprocess.run(), even if kwargs requests otherwise. If False, then sets
	check=False in the call to subprocess.run(), even if kwargs requests
	otherwise. If None, then does not specify check, and leaves kwargs
	untouched.
	"""
	if params.is_dry_run:
		whitespaces = re.compile("\\s")
		cmd_escaped = \
			[arg if whitespaces.search(arg) == None else '"{}"'.format(arg) \
				for arg in cmd]
		print('-- Would run: {}'.format(" ".join(cmd_escaped)))
		return None
	else:
		if check != None:
			kwargs = kwargs.copy()
			kwargs["check"] = check
		return subprocess.run(cmd, **kwargs)

def chdir_or_print(params: Params, dir: str) -> None:
	"""
	Depending on whether we are in a dry run or not, either changes directory,
	or prints that it would do so.
	"""
	if not params.is_dry_run:
		os.chdir(dir)
	else:
		print("-- Would chdir to {}".format(dir))

def set_envvar_or_print(params: Params, envvar: str, value: str) -> None:
	"""
	Depending on whether we are in a dry run or not, either sets envvar,
	or prints that it would do so.
	"""
	if not params.is_dry_run:
		os.environ[envvar] = value
	else:
		print('-- Would set envvar {}="{}"'.format(envvar, value))

def get_default_prj1_preset():
	if sys.platform.startswith("linux"):
		return "linux-shared"
	if sys.platform == "darwin":
		return "osx-shared"
	if sys.platform == "win32":
		return "win-shared"
	raise RuntimeError(
		'[BUG] Could not determine preset name for platform "{}"'
			.format(sys.platform))

def get_default_prj2_preset():
	# Happens to be the same thing as prj1
	return get_default_prj1_preset()

def set_envvars(params: Params) -> None:
	if not "PRJ1_CONFIG" in os.environ:
		print('PRJ1_CONFIG not defined, defaulting to "Release"')
		os.environ["PRJ1_CONFIG"] = "Release"
	if not "PRJ2_CONFIG" in os.environ:
		print('PRJ2_CONFIG not defined, defaulting to "Release"')
		os.environ["PRJ2_CONFIG"] = "Release"
	if not "PRJ1_CONFIGURE_PRESET" in os.environ:
		preset = get_default_prj1_preset()
		print('PRJ1_CONFIGURE_PRESET not defined, defaulting to "{}"'
			.format(preset))
		os.environ["PRJ1_CONFIGURE_PRESET"] = preset
	if not "PRJ2_CONFIGURE_PRESET" in os.environ:
		preset = get_default_prj2_preset()
		print('PRJ2_CONFIGURE_PRESET not defined, defaulting to "{}"'
			.format(preset))
		os.environ["PRJ2_CONFIGURE_PRESET"] = preset
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
		self.ade_clang_format_dir = Path(
			"{}/AdeClangFormat".format(MAIN_SCRIPT_DIR))
		self.prj1_dir = Path(
			"{}/prj1".format(MAIN_SCRIPT_DIR))
		self.prj2_dir = Path(
			"{}/prj2".format(MAIN_SCRIPT_DIR))
		self.install_dir = Path(
			"{}/install".format(MAIN_SCRIPT_DIR))

	def __str__(self) -> str:
		return "cmake_exe: {}, ctest_exe: {}, cpack_exe: {}, vcpkg_dir: {}" \
			.format(self.cmake_exe, self.ctest_exe, self.cpack_exe, \
				self.vcpkg_dir)

def check_cmake_version_has_presets(params: Params, paths: Paths) -> None:
	"""Checks that the version of CMake supports presets."""
	MIN_MAJOR=3
	MIN_MINOR=19

	output = run_or_print_cmd(params, [str(paths.cmake_exe), "--version"], \
		check=True, \
		text=True, \
		stdout=subprocess.PIPE).stdout
	first_line = output.splitlines()[0]
	ver_regex = re.compile(
		"(?P<major>\\d+)\\.(?P<minor>\\d+)\\.(?P<build>\\d+)"
		"(-(?P<patch>.*))?")
	match = ver_regex.search(first_line)
	if match == None:
		raise RuntimeError("[BUG] could not match CMake version number.")
	major = match["major"]
	minor = match["minor"]

	major_int = int(major)
	minor_int = int(minor)

	matches_minimum = major_int > MIN_MAJOR or major_int == MIN_MAJOR and \
		minor_int >= MIN_MINOR
	if not matches_minimum:
		raise RuntimeError(
			"CMake version is less than minimum required ({} < {}.{}).".format(
				match[0],
				MIN_MAJOR,
				MIN_MINOR))
	print("CMake version OK ({} >= {}.{})".format(
		match[0],
		MIN_MAJOR,
		MIN_MINOR))

def check_vcpkg(params: Params, paths: Paths) -> None:
	if not os.listdir(paths.vcpkg_dir):
		# Do not run the git command here: it is frequent to produce tarballs
		# of a repo's sources and then distribute the tarball. If we use a
		# 'git' command here, source tarballs would not work because the
		# extracted tarball is not a Git repo.
		raise RuntimeError(
			"vcpkg dir does not exist; did you clone this repos's submodules? "
			"Run: git submodule update --init --recursive")

def clean_ade_clang_format(params: Params, paths: Paths) -> None:
	"""Deletes all AdeClangFormat build files. Also deletes the install
	directory."""
	if not params.is_dry_run:
		shutil.rmtree(paths.ade_clang_format_dir.joinpath("build"), ignore_errors=True)

def clean_prj1(params: Params, paths: Paths) -> None:
	"""Deletes all prj1 build files. Also deletes the install
	directory."""
	if not params.is_dry_run:
		shutil.rmtree(paths.install_dir, ignore_errors=True)
		shutil.rmtree(paths.prj1_dir.joinpath("build"), ignore_errors=True)

def clean_prj2(params: Params, paths: Paths) -> None:
	"""Deletes all prj2 build files. Also deletes the install
	directory."""
	if not params.is_dry_run:
		shutil.rmtree(paths.install_dir, ignore_errors=True)
		shutil.rmtree(paths.prj2_dir.joinpath("build"), ignore_errors=True)

def build_ade_clang_format(params: Params, paths: Paths) -> None:
	chdir_or_print(params, paths.ade_clang_format_dir)
	# The output of AdeClangFormat is the same regardless of the preset and
	# config/build-type, so just always pick the same one.
	build_config = "Release"
	set_envvar_or_print(params, "CMAKE_BUILD_TYPE", build_config)

	run_or_print_cmd(params, [str(paths.cmake_exe), "-S", ".", "-B", "build", "--install-prefix", str(paths.install_dir)])
	run_or_print_cmd(params, [str(paths.cmake_exe), "--build", "build", "--config", build_config, "-j10"])
	run_or_print_cmd(params, [str(paths.ctest_exe), "--test-dir", "build", "--build-config", build_config, "-j10"])
	run_or_print_cmd(params, [str(paths.cmake_exe), "--install", "build", "--config", build_config])

def build_prj1(params: Params, paths: Paths) -> None:
	chdir_or_print(params, paths.prj1_dir)
	build_config = os.environ["PRJ1_CONFIG"]
	set_envvar_or_print(params, "CMAKE_BUILD_TYPE", build_config)

	run_or_print_cmd(params, [str(paths.cmake_exe), "--preset", os.environ["PRJ1_CONFIGURE_PRESET"]])
	run_or_print_cmd(params, [str(paths.cmake_exe), "--build", "build", "--config", build_config, "-j10"])
	run_or_print_cmd(params, [str(paths.ctest_exe), "--test-dir", "build", "--build-config", build_config, "-j10"])
	run_or_print_cmd(params, [str(paths.cmake_exe), "--install", "build", "--config", build_config])
	if "CPACK_GENERATORS" in os.environ:
		run_or_print_cmd(params, [str(paths.cpack_exe), "-G", os.environ["CPACK_GENERATORS"], "-C", build_config, "--config", "build/CPackConfig.cmake"])

def build_prj2(params: Params, paths: Paths) -> None:
	chdir_or_print(params, paths.prj2_dir)
	build_config = os.environ["PRJ2_CONFIG"]
	set_envvar_or_print(params, "CMAKE_BUILD_TYPE", build_config)

	run_or_print_cmd(params, [str(paths.cmake_exe), "--preset", os.environ["PRJ2_CONFIGURE_PRESET"]])
	run_or_print_cmd(params, [str(paths.cmake_exe), "--build", "build", "--config", build_config, "-j10"])
	run_or_print_cmd(params, [str(paths.ctest_exe), "--test-dir", "build", "--build-config", build_config, "-j10"])
	run_or_print_cmd(params, [str(paths.cmake_exe), "--install", "build", "--config", build_config])
	if "CPACK_GENERATORS" in os.environ:
		run_or_print_cmd(params, [str(paths.cpack_exe), "-G", os.environ["CPACK_GENERATORS"], "-C", build_config, "--config", "build/CPackConfig.cmake"])

def run_exe(params: Params, paths: Paths) -> None:
	IS_WINDOWS = sys.platform == "win32"
	run_or_print_cmd(params, \
		["{}/bin/exe{}".format(
			paths.install_dir, ".exe" if IS_WINDOWS else "")])

def run() -> None:
	params = parse_args()
	set_envvars(params)
	paths = Paths(params)
	if not params.is_dry_run:
		check_cmake_version_has_presets(params, paths)
		check_vcpkg(params, paths)
	clean_ade_clang_format(params, paths)
	clean_prj1(params, paths)
	clean_prj2(params, paths)
	build_ade_clang_format(params, paths)
	build_prj1(params, paths)
	build_prj2(params, paths)
	if params.run_exe:
		run_exe(params, paths)

if __name__ == "__main__":
	run()
