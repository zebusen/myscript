#!/usr/bin/env bash
echo "Cloning dependencies"
# git clone --depth=1 --quiet https://github.com/kdrag0n/proton-clang clang
sudo add-apt-repository ppa:ubuntu-toolchain-r/test -y && sudo apt-get update
sudo apt-get install flex bison ncurses-dev texinfo gcc gperf patch libtool automake g++ libncurses5-dev gawk subversion expat libexpat1-dev python-all-dev binutils-dev bc libcap-dev autoconf libgmp-dev build-essential pkg-config libmpc-dev libmpfr-dev autopoint gettext txt2man liblzma-dev libssl-dev libz-dev mercurial wget tar gcc-10 g++-10 --fix-broken --fix-missing
git clone --depth=1 https://github.com/osm0sis/AnyKernel3 AnyKernel
echo "Done"
IMAGE=$(pwd)/out/arch/arm64/boot/Image.gz-dtb
TANGGAL=$(date +"%F-%S")
START=$(date +"%s")
KERNEL_DIR=$(pwd)
# PATH="${PWD}/clang/bin:$PATH"
# export KBUILD_COMPILER_STRING="$(${KERNEL_DIR}/clang/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')"
export KBUILD_BUILD_HOST=circleci
export KBUILD_BUILD_USER="mikofan"
function sendinfo() {
    curl -s -X POST "https://api.telegram.org/bot1628360095:AAF947lAXmKVaw9jRpx-CURb_wK2FZKl9z8/sendMessage" \
        -d chat_id="-1001214166550" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=html" \
        -d text="cook"
}
# Push kernel to channel
function eva() {
git clone --depth=1 https://github.com/mvaisakh/gcc-arm64.git -b lld-integration gcc64
		git clone --depth=1 https://github.com/mvaisakh/gcc-arm.git -b lld-integration gcc32
		GCC64_DIR=$KERNEL_DIR/gcc64
		GCC32_DIR=$KERNEL_DIR/gcc32
export KBUILD_COMPILER_STRING=$("$GCC64_DIR"/bin/aarch64-elf-gcc --version | head -n 1)
PATH=$GCC64_DIR/bin/:$GCC32_DIR/bin/:/usr/bin:$PATH
}
function push() {
    cd AnyKernel
    ZIP=$(echo *.zip)
    curl -F document=@$ZIP "https://api.telegram.org/bot1628360095:AAF947lAXmKVaw9jRpx-CURb_wK2FZKl9z8/sendDocument" \
        -F chat_id="-1001214166550" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html" \
        -F caption="Build took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) second(s). | For <b>WHYRED</b> | using EvaGCC (I'll update this everytime when I change compiler)"
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
export ARCH=arm64
export SUBARCH=arm64
    cd /root/project/android_kernel_xiaomi_whyred
    make O=out ARCH=arm64 whyred_defconfig
    
    make -j$(nproc --all) O=out \
                          ARCH=arm64 \
			  CROSS_COMPILE=aarch64-elf- \
			  CROSS_COMPILE_ARM32=$GCC32_DIR/bin/arm-eabi-
    cp out/arch/arm64/boot/Image.gz-dtb /root/project/AnyKernel
}
# Zipping
function zipping() {
    cd /root/project/AnyKernel || exit 1
    zip -r9 personal-eas-rad.zip *
    cd ..
}
eva
sendinfo
compile
zipping
END=$(date +"%s")
DIFF=$(($END - $START))
push
