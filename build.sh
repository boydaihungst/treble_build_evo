#!/bin/bash

echo
echo "--------------------------------------"
echo "          Evolution X 14.0 Buildbo    "
echo "                  by                  "
echo "              boydaihungs             "
echo "         Origin author: ponces        "
echo "--------------------------------------"
echo

set -e

BL=$PWD/treble_build_evo
OUT="out/target/product/tdgsi_arm64_ab"
buildDate="$(date +%Y%m%d)"
version="$(date +v%Y.%m.%d)"
START=$(date +%s)
timestamp="$START"

initRepos() {
    if [ ! -d .repo ]; then
        echo "--> Initializing workspace"
        repo init -u https://github.com/Evolution-X/manifest -b udc
        echo

        echo "--> Preparing local manifest"
        mkdir -p .repo/local_manifests
        cp $BL/manifest.xml .repo/local_manifests/
        echo
    fi
}

syncRepos() {
    echo "--> Syncing repos"
    # repo sync -c --force-sync --no-clone-bundle --no-tags -j$(nproc --all)
    echo
}

applyPatches() {
    echo "--> Applying patches"
    bash $BL/apply-patches.sh .
    echo

    echo "--> Generating makefiles"
    pushd ./device/phh/treble/ &>/dev/null
      cp $BL/evo.mk ./
      bash generate.sh evo
    popd &>/dev/null
    echo
}

setupEnv() {
    echo "--> Setting up build environment"
    source build/envsetup.sh
    echo
}

buildGappsVariant() {
    echo "--> Building treble_arm64_bvN"
    lunch treble_arm64_bvN-userdebug
    make -j$(nproc --all) systemimage
    echo
}

generatePackages() {
    echo "--> Generating packages"
    pushd $OUT/ &>/dev/null
      mv system.img evolution-x-arm64-ab-gapps-14.0-$buildDate.img
      echo "--> Compressing packages"
      xz -cv evolution-x-arm64-ab-gapps-14.0-$buildDate.img -T0 > evolution-x-arm64-ab-gapps-14.0-$buildDate.img.xz
    popd &>/dev/null
    echo
}

generateOta() {
    echo "--> Generating OTA file"

    json="{\"version\": \"$version\",\"date\": \"$timestamp\",\"variants\": ["
    find $OUT/ -name "evolution-x-*-14.0-$buildDate.img.xz" | sort | {
        while read file; do
            filename="$(basename $file)"
            if [[ $filename == *"vanilla-vndklite"* ]]; then
                name="treble_arm64_bvN-vndklite"
            elif [[ $filename == *"gapps-vndklite"* ]]; then
                name="treble_arm64_bgN-vndklite"
            elif [[ $filename == *"vanilla"* ]]; then
                name="treble_arm64_bvN"
            else
                name="treble_arm64_bgN"
            fi
            size=$(wc -c $file | awk '{print $1}')
            url="https://sourceforge.net/projects/nubia-6s-pro-pixel-gsi/files/evo_android_14/$filename/download"
            json="${json} {\"name\": \"$name\",\"size\": \"$size\",\"url\": \"$url\"},"
        done
        json="${json%?}]}"
        echo "$json" | jq . > $BL/ota.json
    }
    echo
}

release() {
    if [[ $(git config user.email) == *"boydaihungst@"* ]]; then
      pushd $OUT/ &>/dev/null
        echo "--> Uploading rom"
        rsync -avP -e ssh evolution-x-arm64-ab-gapps-14.0-$buildDate.img.xz sourceforge:/home/frs/project/nubia-6s-pro-pixel-gsi/evo_android_14/
      popd &>/dev/null

      echo "--> Uploading ota file"
      pushd $BL/ &>/dev/null
        git add --all || true
        git commit -m "update: ota + patches" || true
        git push 
      popd &>/dev/null
    fi
}


initRepos
syncRepos
applyPatches
setupEnv
buildGappsVariant
generatePackages
generateOta
release
END=$(date +%s)
ELAPSEDM=$(($(($END-$START))/60))
ELAPSEDS=$(($(($END-$START))-$ELAPSEDM*60))

echo "--> Buildbot completed in $ELAPSEDM minutes and $ELAPSEDS seconds"
echo
