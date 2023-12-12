#!/usr/bin/env python3
# SPDX-License-Identifier: MIT
import argparse

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

def run():
	params = parse_args()

if __name__ == "__main__":
	run()
