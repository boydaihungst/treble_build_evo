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

GIT_REPO="treble_build_evo"
GIT_OWNER="boydaihungst"

BL="$PWD/$GIT_REPO"
OUT="out/target/product/tdgsi_arm64_ab"
BD="$PWD/GSIs"
EVO_BASE_VERSION="8"

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
    repo sync -c --force-sync --no-clone-bundle --no-tags -j$(nproc --all)
    echo
}

applyPatches() {
    echo "--> Applying patches"
    bash $BL/apply-patches.sh .
    echo

    echo "--> Generating makefiles"
    cp $BL/evo.mk ./device/phh/treble/
    pushd ./device/phh/treble/ &>/dev/null
      bash generate.sh evo
    popd &>/dev/null
    echo
}

setupEnv() {
    echo "--> Setting up build environment"
    source build/envsetup.sh
    mkdir -p $BD
    echo
}

buildGappsVariant() {
    echo "--> Building treble_arm64_bvN"
    lunch treble_arm64_bvN-userdebug
    make -j$(nproc --all) systemimage
    mv $OUT/system.img $BD/system-treble_arm64_bvN.img
    echo
}

buildMiniVariant() {
    echo "--> Building treble_arm64_bvN-mini"
    (cd vendor/evolution && git am $BL/patches/mini/platform_vendor_evolution/mini-evolution.patch)
    (cd vendor/gms && git am $BL/patches/mini/platform_vendor_gms/mini-gms.patch)
    lunch treble_arm64_bvN-userdebug
    make -j$(nproc --all) systemimage
    (cd vendor/evolution && git reset --hard HEAD~1)
    (cd vendor/gms && git reset --hard HEAD~1)
    mv $OUT/system.img $BD/system-treble_arm64_bvN-mini.img
    echo
}

buildVndkliteVariant() {
    echo "--> Building treble_arm64_bvN-vndklite"
    pushd sas-creator/ &>/dev/null
      sudo bash lite-adapter.sh 64 $BD/system-treble_arm64_bvN.img
      cp s.img $BD/system-treble_arm64_bvN-vndklite.img
      sudo rm -rf s.img d tmp

      sudo bash lite-adapter.sh 64 $BD/system-treble_arm64_bvN-mini.img
      cp s.img $BD/system-treble_arm64_bvN-mini-vndklite.img
      sudo rm -rf s.img d tmp

    popd &>/dev/null
    echo
}

generatePackages() {
    echo "--> Generating packages"
    xz -cv $BD/system-treble_arm64_bvN.img -T0 > "$BD/evolution_arm64-ab-$EVO_BASE_VERSION-unofficial-$buildDate.img.xz"
    xz -cv $BD/system-treble_arm64_bvN-vndklite.img -T0 > "$BD/evolution_arm64-ab-vndklite-$EVO_BASE_VERSION-unofficial-$buildDate.img.xz"
    xz -cv $BD/system-treble_arm64_bvN-mini.img -T0 > "$BD/evolution_arm64-ab-mini-$EVO_BASE_VERSION-unofficial-$buildDate.img.xz"
    xz -cv $BD/system-treble_arm64_bvN-mini-vndklite.img -T0 > "$BD/evolution_arm64-ab-mini-vndklite-$EVO_BASE_VERSION-unofficial-$buildDate.img.xz"
    # rm -rf $BD/system-*.img
    echo
}

generateOta() {
    echo "--> Generating OTA file"
    version="$(date +v%Y.%m.%d)"
    timestamp="$START"
    json="{\"version\": \"$version\",\"date\": \"$timestamp\",\"variants\": ["
    find $BD/ -name "evolution_*" | sort | {
        while read file; do
            filename="$(basename $file)"
            if [[ $filename == *"vndklite"* ]]; then
                name="treble_arm64_bvN-vndklite"
            elif [[ $filename == *"mini"* ]]; then
                name="treble_arm64_bvN-mini"
            else
                name="treble_arm64_bvN"
            fi
            size=$(wc -c $file | awk '{print $1}')
            url="https://github.com/$GIT_OWNER/$GIT_REPO/releases/download/$version/$filename"
            json="${json} {\"name\": \"$name\",\"size\": \"$size\",\"url\": \"$url\"},"
        done
        json="${json%?}]}"
        echo "$json" | jq . > $BL/ota.json
    }
    echo
}

release() {
    if [[ $(git config user.email) == *"$GIT_OWNER@"* ]]; then
      # pushd $BD/ &>/dev/null
      #   echo "--> Uploading rom"
      #     gh api \
      #     --method POST \
      #     -H "Accept: application/vnd.github+json" \
      #     -H "X-GitHub-Api-Version: 2022-11-28" \
      #     /repos/$GIT_OWNER\/$GIT_REPO/releases \
      #     -f tag_name="$version" \
      #     -f target_commitish='udc_A14' \
      #     -f name="$version" \
      #     -F draft=false \
      #     -F prerelease=false \
      #     -F generate_release_notes=false


      #     find $BD/ -name "evolution_*.img.xz" | sort | {
      #       while read file; do
      #         filename="$(basename $file)"
      #         gh release upload $version "$file" --repo boydaihungst/treble_build_evo --clobber
      #       done
      #     }
      # popd &>/dev/null

      echo "--> Uploading ota file"
      pushd $BL/ &>/dev/null
        git add --all || true
        git commit -m "update: ota + patches" || true
        git push 
      popd &>/dev/null
    fi
}

# initRepos
# syncRepos
# applyPatches
# setupEnv
# buildGappsVariant
# buildMiniVariant
# buildVndkliteVariant
# generatePackages
generateOta
release
END=$(date +%s)
ELAPSEDM=$(($(($END-$START))/60))
ELAPSEDS=$(($(($END-$START))-$ELAPSEDM*60))

echo "--> Buildbot completed in $ELAPSEDM minutes and $ELAPSEDS seconds"
echo
