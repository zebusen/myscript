#!/usr/bin/env bash


export TZ=Asia/Taipei

# Configure git
git config --global user.name "Zebusen"
git config --global user.email "zebusensei@gmail.com"
export ARCH=arm64
export KBUILD_BUILD_HOST=circleci
export KBUILD_BUILD_USER="zebusen"
git clone --depth=1 --quiet https://github.com/osm0sis/AnyKernel3 -b master
function compile() {
    cd /root/project/android_kernel_xiaomi_sdm660
    make O=out ARCH=arm64 whyred_defconfig
    make -j$(nproc --all) O=out \
                          ARCH=arm64 \
			  CC=clang \
			  CROSS_COMPILE=aarch64-linux-gnu- \
			  CROSS_COMPILE_ARM32=arm-linux-gnueabi-

    cp out/arch/arm64/boot/Image.gz-dtb AnyKernel
    
    }
    function zipit(){
      cd AnyKernel || exit 1
      zip -r9 personal-rad-hmp-oldcam.zip *
      cd ..
    }
    function inform() {
     curl -s -X POST "https://api.telegram.org/bot1628360095:AAF947lAXmKVaw9jRpx-CURb_wK2FZKl9z8/sendMessage" \
      -d chat_id="-1001214166550" \
      -d text="Cooking"
    }
    function push(){
    cd AnyKernel
    curl -F document=@"personal-rad-hmp-oldcam.zip" "https://api.telegram.org/bot1628360095:AAF947lAXmKVaw9jRpx-CURb_wK2FZKl9z8/sendDocument" \
      -F chat_id="-1001214166550" \
      -F "disable_web_page_preview=true" \
      -F "parse_mode=html" \
    }
    inform
    compile
    zipit
    push
