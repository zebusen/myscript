#!/usr/bin/env bash
echo "Cloning dependencies"
git clone --depth=1 --quiet https://github.com/kdrag0n/proton-clang clang
git clone --depth=1 https://github.com/Reinazhard/AnyKernel3 AnyKernel

echo "Done"
IMAGE=$(pwd)/out/arch/arm64/boot/Image.gz-dtb
TANGGAL=$(date +"%F-%S")
START=$(date +"%s")
KERNEL_DIR=$(pwd)
PATH="${PWD}/clang/bin:$PATH"
export KBUILD_COMPILER_STRING="$(${KERNEL_DIR}/clang/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')"
export ARCH=arm64
export KBUILD_BUILD_HOST=hololive
export KBUILD_BUILD_USER="mikofan"
function sendinfo() {
    curl -s -X POST "https://api.telegram.org/bot1628360095:AAF947lAXmKVaw9jRpx-CURb_wK2FZKl9z8/sendMessage" \
        -d chat_id="-1001214166550" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=html" \
        -d text="cook"
}
function fixcharger() {
echo "Add commit for fixing charging"
cd /root/project/android_kernel_xiaomi_whyred
git config uploadpack.allowReachableSHA1InWant true
git remote add zebu https://github.com/theradcolor/android_kernel_xiaomi_whyred.git
git fetch --shallow-since=2021-02-01 zebu
git cherry-pick ec27b2960cdca9fd2d5df46da21b20a90387be3a
git remote add zebu2 https://github.com/SreekanthPalakurthi/kranul
git fetch --shallow-since=2021-01-31 zebu2
git cherry-pick f14650b1984e23a1304eaee8aeae629414c92801
git remote add zebu3 https://github.com/silont-project/android_kernel_xiaomi_sdm660.git
git fetch --shallow-since=2021-03-01 zebu3
git cherry-pick f1c027459f9b64cdeffbeebe29b3ad8e5cbcff52
git cherry-pick c145b110c219fba64565a40969cebbc39a406045
git cherry-pick 2d15b8351146e87d4846299ddc039e996229143c
#iommu
git cherry-pick 75b4dde4b0112f6c534ae55a688b58c62322464f
#ion
git cherry-pick 94bcb90005aedb5ae5775c60d6f0d78fdde98edd
git cherry-pick 2d15b8351146e87d4846299ddc039e996229143c
git cherry-pick 4a0f7b78ae41e8a751702c0af509c0123cc8d181
git cherry-pick 8e97cf26101c770c31bc18ff4d12490b83d95144
git cherry-pick 019fb94be69e9b243517efaab3fbb7d23db01ab9

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
    make -j$(nproc) O=out ARCH=arm64 whyred-newcam_defconfig
        make -j$(nproc) ARCH=arm64 O=out \
                                       CROSS_COMPILE=aarch64-linux-gnu- \
                                                                      CROSS_COMPILE_ARM32=arm-linux-gnueabi-
     cp out/arch/arm64/boot/Image.gz-dtb /root/project/AnyKernel                                                              
   }
function compileclang() {
    cd /root/project/android_kernel_xiaomi_whyred
    make O=out ARCH=arm64 whyred_defconfig
    make -j$(nproc --all) O=out \
                          ARCH=arm64 \
                          CC=clang \
			  CROSS_COMPILE=aarch64-linux-gnu- \
			  CROSS_COMPILE_ARM32=arm-linux-gnueabi-
    cp out/arch/arm64/boot/Image.gz-dtb /root/project/AnyKernel
}
# Zipping
function zipping() {
    cd /root/project/AnyKernel || exit 1
    zip -r9 personal-oldcam-radhmp.zip *
    cd ..
}
sendinfo
fixcharger
compileclang
zipping
END=$(date +"%s")
DIFF=$(($END - $START))
push
