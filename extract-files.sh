#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017-2020 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

DEVICE=joan
VENDOR=lge

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}/../../.."

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true

KANG=
SECTION=

while [ "${#}" -gt 0 ]; do
    case "${1}" in

        -n | --no-cleanup )
                CLEAN_VENDOR=false
                ;;
        -k | --kang )
                KANG="--kang"
                ;;
        -s | --section )
                SECTION="${2}"; shift
                CLEAN_VENDOR=false
                ;;
        * )
                SRC="${1}"
                ;;
    esac
    shift
done

if [ -z "${SRC}" ]; then
    SRC="adb"
fi

function blob_fixup() {
    case "${1}" in
    vendor/lib/hw/audio.primary.msm8998.so)
        ${PATCHELF} --add-needed libprocessgroup.so "${2}"
        ;;
    vendor/lib64/hw/audio.primary.msm8998.so)
        ${PATCHELF} --add-needed libprocessgroup.so "${2}"
        ;;
    vendor/lib/hw/camera.msm8998.so)
        sed -i "s/libandroid\.so/libui_shim\.so/g" "${2}"
        ${PATCHELF} --remove-needed libsensor.so "${2}"
        ${PATCHELF} --remove-needed libgui.so "${2}"
        ${PATCHELF} --remove-needed libui.so "${2}"
        ;;
    vendor/lib/libmpbase.so)
        ${PATCHELF} --remove-needed libandroid.so "${2}"
        ;;
    vendor/lib/libarcsoft_beauty_picselfie.so)
        ${PATCHELF} --remove-needed libandroid.so "${2}"
        ${PATCHELF} --remove-needed libjnigraphics.so "${2}"
        ;;
    vendor/lib/libfilm_emulation.so)
        ${PATCHELF} --remove-needed libjnigraphics.so "${2}"
        ;;
    vendor/lib/libmmcamera_bokeh.so)
        ${PATCHELF} --replace-needed libui.so libui_shim.so "${2}"
        ;;
    esac
}





"${MY_DIR}/setup-makefiles.sh"
