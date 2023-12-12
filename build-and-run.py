#!/usr/bin/env python3
# SPDX-License-Identifier: MIT
import argparse
import inspect
import os

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

def run():
	params = parse_args()
	set_envvars(params)

if __name__ == "__main__":
	run()
