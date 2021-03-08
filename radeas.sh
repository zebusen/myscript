#!/usr/bin/env bash
echo "Cloning dependencies"
git clone --depth=1 --quiet https://github.com/kdrag0n/proton-clang clang
git clone --depth=1 https://github.com/sohamxda7/AnyKernel3 AnyKernel
echo "Done"
IMAGE=$(pwd)/out/arch/arm64/boot/Image.gz-dtb
TANGGAL=$(date +"%F-%S")
START=$(date +"%s")
KERNEL_DIR=$(pwd)
PATH="${PWD}/clang/bin:$PATH"
export KBUILD_COMPILER_STRING="$(${KERNEL_DIR}/clang/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')"
export ARCH=arm64
export KBUILD_BUILD_HOST=miyauchi
export KBUILD_BUILD_USER="renge"
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
    ZIP=$(echo *.zip)
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
function compile() {
    cd /root/project/android_kernel_xiaomi_whyred
    make O=out ARCH=arm64 whyred_defconfig
    make -j$(nproc --all) O=out \
                          ARCH=arm64 \
			  CC=clang \
			  CROSS_COMPILE=aarch64-linux-gnu- \
			  CROSS_COMPILE_ARM32=arm-linux-gnueabi-
    cp out/arch/arm64/boot/Image.gz-dtb /root/project/AnyKernel
}
function fixcharger() {
echo "Add commit for fixing charging"
cd /root/project/android_kernel_xiaomi_whyred
git config uploadpack.allowReachableSHA1InWant true
git remote add zebu2 https://github.com/SreekanthPalakurthi/kranul
git fetch --shallow-since=2020-06-31 zebu2
git cherry-pick f14650b1984e23a1304eaee8aeae629414c92801
git cherry-pick c491c59c4a762a03b41078707a0f08f0c8e2431f
git cherry-pick b2c890885a0cee05f12e9d8910168c8099248023
git cherry-pick fd00fab3ffcee93bea2fda00e21ddf8eb24630c1
}
# Zipping
function zipping() {
    cd /root/project/AnyKernel || exit 1
    zip -r9 personal-eas-rad$(date).zip *
    cd ..
}
sendinfo
fixcharger
compile
zipping
END=$(date +"%s")
DIFF=$(($END - $START))
push
