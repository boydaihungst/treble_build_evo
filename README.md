# Evolution X GSI

## Build

To get started with building Evolution X GSI, you'll need to get familiar with [Git and Repo](https://source.android.com/source/using-repo.html) as well as [How to build a GSI](https://github.com/phhusson/treble_experimentations/wiki/How-to-build-a-GSI%3F).

- Environment setup:

[EndeavouOS/arch based distros](https://github.com/ponces/treble_build_aosp/issues/11#issuecomment-1760898373)

- Create a new working directory for your Evolution X build and navigate to it:

    ```sh
    mkdir evolution; cd evolution
    ```

- Clone this repo:

    ```sh
    git clone https://github.com/boydaihungst/treble_build_evo -b udc_A14
    ```

- Finally, start the build script:

    ```sh
    bash treble_build_evo/build.sh
    ```

## Notes

- In case you want to revert all patches:

```sh
bash ./patches/revert-patches.sh .
```

- In case you are facing any patch error:

```sh
# Error at patch: trebledroid/platform_framework_base/0002-Fallback-to-stupid-autobrightness-if-brightness-valu.patch
# Go to framework/base folder:
cd framework/base
# Check error patch and edit source as you want. After done editing:
git add --all && git commit -m "Fallback-to-stupid-autobrightness-if-brightness-valu" && git format-patch HEAD~1
# new patch will be created `framework/base/0001-...`, Rename to `0002-...`,then replace `trebledroid/platform_framework_base/0002-Fallback-to-stupid-autobrightness-if-brightness-valu.patch`
# After fixed patch file, run this command to check if there is any other error patch
bash ./patches/apply-patches.sh .
```

- In case you want to add new patch:

```sh
# Run 
bash ./patches/apply-patches.sh .
# eg: framework/base
cd framework/base
# edit source code. Then run:
git add --all && git commit -m "REPLACE_THIS_WITH_PATCH_NAME" && git format-patch HEAD~1
# You can create multiple patch files: 
git format-patch HEAD~40 # This will create 40 patches from 0001-... to 0040-... based on the last 40 commits.
# copy new patch file to misc/platform_framework_base
```

- First and foremost, a huge thanks to David Dean for providing me with an incredible building server which helps (by a lot!!) delivering these builds as fast as possible.
- If bluetooth calls or bluetooth media do not work well for you, make sure you have the "Use System Wide BT HAL" checkbox enabled on the Misc page of Treble App. If not, enable and reboot.
- If you have a non-Samsung device with a Qualcomm chipset and VoLTE isn't working with the default IMS package provided by Treble App, try installing this [alternative IMS package](https://treble.phh.me/stable/ims-caf-s.apk).

## Credits

These people have helped this project in some way or another, so they should be the ones who receive all the credit:

- [Evolution X Team](https://evolution-x.org)
- [phhusson](https://github.com/phhusson)
- [AndyYan](https://github.com/AndyCGYan)
- [eremitein](https://github.com/eremitein)
- [kdrag0n](https://github.com/kdrag0n)
- [Peter Cai](https://github.com/PeterCxy)
- [haridhayal11](https://github.com/haridhayal11)
- [sooti](https://github.com/sooti)
- [Iceows](https://github.com/Iceows)
- [ChonDoit](https://github.com/ChonDoit)
- [Ponces](https://github.com/ponces)
