#!/bin/bash

set -e

croot_dir="$(readlink -f -- $1)"

revert() {
	tree="$1"

	for project in $(
		cd $croot_dir/treble_build_evo/patches/$tree
		echo *
	); do
		p="$(tr _ / <<<$project | sed -e 's;platform/;;g')"
		[ "$p" == build ] && p=build/make
		[ "$p" == treble/app ] && p=treble_app
		[ "$p" == vendor/hardware/overlay ] && p=vendor/hardware_overlay
		pushd $p &>/dev/null
    git am --abort &>/dev/null || true
		git reset --hard FETCH_HEAD
		popd &>/dev/null
	done
}
revert pre
revert trebledroid
revert misc
revert mini
