#!/usr/bin/env bash
echo "Cloning dependencies"
git clone --depth=1 https://github.com/osm0sis/AnyKernel3 AnyKernel
echo "Done"
IMAGE=$(pwd)/out/arch/arm64/boot/Image.gz-dtb
TANGGAL=$(date +"%F-%S")
START=$(date +"%s")
KERNEL_DIR=$(pwd)
export KBUILD_BUILD_HOST=circleci
export KBUILD_BUILD_USER="miko35"
function sendinfo() {
    curl -s -X POST "https://api.telegram.org/bot1628360095:AAF947lAXmKVaw9jRpx-CURb_wK2FZKl9z8/sendMessage" \
        -d chat_id="-1001214166550" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=html" \
        -d text="cook"
}
# Push kernel to channel
function push() {
    cd AnyKernel
    ZIP=$(echo *.zip) \
    curl -F document=@$ZIP "https://api.telegram.org/bot1628360095:AAF947lAXmKVaw9jRpx-CURb_wK2FZKl9z8/sendDocument" \
        -F chat_id="-1001214166550" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html" \
        -F caption="Build took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) second(s). | For <b>WHYRED</b> | using Proton Clang (I'll update this everytime when I change compiler)"
}
# Fin Error
function finerr() {
    curl -s -X POST "https://api.telegram.org/bot1628360095:AAF947lAXmKVaw9jRpx-CURb_wK2FZKl9z8/sendMessage" \
        -d chat_id="-1001214166550" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=markdown" \
        -d text="Build throw an error(s)"
    exit 1
}
# Compile plox

# Zipping
function zipping() {
    cd /root/project/AnyKernel || exit 1
    zip -r9 personal-eas-rad.zip *
    cd ..
}
function clone_gcc()
{
    git clone --depth=1 --quiet https://github.com/theradcolor/arm-linux-gnueabi -b ${GCC_BRANCH} gcc32
    git clone --depth=1 --quiet https://github.com/theradcolor/aarch64-linux-gnu -b ${GCC_BRANCH} gcc64
}
function set_param_gcc()
{
    #Export compiler dir.
    export CROSS_COMPILE=$WD"/gcc64/bin/aarch64-linux-gnu-"
    export CROSS_COMPILE_ARM32=$WD"/gcc32/bin/arm-linux-gnueabi-"

    # Export ARCH <arm, arm64, x86, x86_64>
    export ARCH=arm64
    #Export SUBARCH <arm, arm64, x86, x86_64>
    export SUBARCH=arm64

    # Kbuild host and user
    export KBUILD_JOBS="$((`grep -c '^processor' /proc/cpuinfo` * 2))"

    TC=$WD/gcc64/bin/aarch64-linux-gnu-gcc
    COMPILER_STRING="$(${WD}"/gcc64/bin/aarch64-linux-gnu-gcc" --version | head -n 1)"
    export KBUILD_COMPILER_STRING="${COMPILER_STRING}"

    export COMPILER_HEAD_COMMIT=$(cd gcc64 && git rev-parse HEAD)
    export COMPILER_HEAD_COMMIT_URL="https://github.com/theradcolor/aarch64-linux-gnu/commit/${COMPILER_HEAD_COMMIT}"
}

function build_gcc()
{
    clone_gcc
    set_param_gcc
    # Push build message to telegram

    # Patch kernel for LTO
    cd /root/project/android_kernel_xiaomi_whyred

    make O="${OUT}" "whyred_defconfig"

    BUILD_START=$(date +"%s")

    # Build
}
sendinfo
build_gcc
zipping
push
