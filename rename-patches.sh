#!/bin/bash

set -e

croot_dir="$(readlink -f -- $1)"
"$croot_dir"/treble_build_evo/revert-patches.sh $croot_dir

rename_patch() {
	tree="$1"

	for project in $(
		cd $croot_dir/treble_build_evo/patches/$tree
		echo *
	); do
		p="$(tr _ / <<<$project | sed -e 's;platform/;;g')"
		[ "$p" == build ] && p=build/make
		[ "$p" == treble/app ] && p=treble_app
		[ "$p" == vendor/hardware/overlay ] && p=vendor/hardware_overlay
    patch_counter=0
		pushd $p &>/dev/null
		for patch in $croot_dir/treble_build_evo/patches/$tree/$project/*.patch; do
      echo "___file: $patch"
			git am $patch || exit
      patch_counter++
		done
    # generate patches name
    if [[ $patch_counter -gt 0 ]]; then
      rm -rf $croot_dir/treble_build_evo/patches/$tree/$project/*
      git format-patch -o "$croot_dir/treble_build_evo/patches/$tree/$project/" HEAD~$patch_counter
    fi
		popd &>/dev/null
	done
}
rename_patch pre
rename_patch trebledroid
rename_patch misc
