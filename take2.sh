#!/usr/bin/env bash
echo "Cloning dependencies"
sudo add-apt-repository ppa:ubuntu-toolchain-r/test -y && sudo apt-get update
sudo apt-get install flex bison ncurses-dev texinfo gcc gperf patch libtool automake g++ libncurses5-dev gawk subversion expat libexpat1-dev python-all-dev binutils-dev bc libcap-dev autoconf libgmp-dev build-essential pkg-config libmpc-dev libmpfr-dev autopoint gettext txt2man liblzma-dev libssl-dev libz-dev mercurial wget tar gcc-10 g++-10 --fix-broken --fix-missing
git clone https://github.com/mvaisakh/gcc-build.git gcc-build
cd /root/project/gcc-build
./build-gcc.sh -a <arm64> 
clone() {
	cd/root/project
	echo " "
		msg "|| Cloning GCC 9.3.0 baremetal ||"
		git clone --depth=1 https://github.com/mvaisakh/gcc-arm64.git gcc64
		git clone --depth=1 https://github.com/mvaisakh/gcc-arm.git gcc32
		GCC64_DIR=$KERNEL_DIR/gcc64
		GCC32_DIR=$KERNEL_DIR/gcc32

	msg "|| Cloning Anykernel ||"
	git clone --depth 1 https://github.com/osm0sis/AnyKernel3.git
}

exports() {
	export KBUILD_BUILD_USER="reina"
	export KBUILD_COMPILER_STRING="GCC 10.2 LTO"
	export ARCH=arm64
	export SUBARCH=arm64

	KBUILD_COMPILER_STRING=$("$GCC64_DIR"/bin/aarch64-elf-gcc --version | head -n 1)
	PATH=$GCC64_DIR/bin/:$GCC32_DIR/bin/:/usr/bin:$PATH

	export PATH KBUILD_COMPILER_STRING
	export BOT_MSG_URL="https://api.telegram.org/bot1628360095:AAF947lAXmKVaw9jRpx-CURb_wK2FZKl9z8/sendMessage"
	export BOT_BUILD_URL="https://api.telegram.org/bot1628360095:AAF947lAXmKVaw9jRpx-CURb_wK2FZKl9z8/sendDocument"
	PROCS=$(nproc --all)
	export PROCS
}
tg_post_msg() {
	curl -s -X POST "$BOT_MSG_URL" -d chat_id="-1001214166550" \
	-d "disable_web_page_preview=true" \
	-d "parse_mode=html" \
	-d text="$1"

}

tg_post_build() {
	#Post MD5Checksum alongwith for easeness
	MD5CHECK=$(md5sum "$1" | cut -d' ' -f1)

	#Show the Checksum alongwith caption
	curl --progress-bar -F document=@"$1" "$BOT_BUILD_URL" \
	-F chat_id="-1001214166550"  \
	-F "disable_web_page_preview=true" \
	-F "parse_mode=html" \
	-F caption="$3 | <code>Build Number : </code><b>$DRONE_BUILD_NUMBER</b>"  
}
build_kernel() {
	msg "|| Started Compilation ||"
	export CROSS_COMPILE_ARM32=$GCC32_DIR/bin/arm-eabi-
  cd /root/project/android_kernel_xiaomi_whyred
	make -j"$PROCS" O=out whyred_defconfig CROSS_COMPILE=aarch64-elf-

		BUILD_END=$(date +"%s")
		DIFF=$((BUILD_END - BUILD_START))
	
}
gen_zip() {
    cd /root/project/AnyKernel || exit 1
    zip -r9 personal-hmp-rad.zip *
    cd ..
}
clone
exports
build_kernel
gen_zip
tg_post_build
