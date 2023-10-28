#!/bin/bash

set -e

croot_dir="$(readlink -f -- $1)"
"$croot_dir"/treble_build_evo/revert-patches.sh $croot_dir

apply() {
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
		for patch in $croot_dir/treble_build_evo/patches/$tree/$project/*.patch; do
      echo "___file: $patch"
			git am $patch || exit
		done
		popd &>/dev/null
	done
}
apply pre
apply trebledroid
apply misc
