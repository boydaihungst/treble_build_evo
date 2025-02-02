$(call inherit-product, vendor/evolution/config/common_full_phone.mk)
$(call inherit-product, vendor/evolution/config/BoardConfigSoong.mk)
$(call inherit-product, device/evolution/sepolicy/common/sepolicy.mk)
-include vendor/evolution/build/core/config.mk

BOARD_EXT4_SHARE_DUP_BLOCKS := true

TARGET_BOOT_ANIMATION_RES := 1080

TARGET_SUPPORTS_QUICK_TAP := true

TARGET_BUILD_APERTURE_CAMERA := true

TARGET_SUPPORTS_TOUCHGESTURES := true

PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.system.ota.json_url=https://raw.githubusercontent.com/boydaihungst/treble_build_evo/udc_A14/ota.json
