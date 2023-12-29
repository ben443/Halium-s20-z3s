#!/bin/bash

mkdir kout
export CDIR="$(pwd)"
export LOG_FILE=puppy.log
export OUT_DIR="/home/chanz/Documentos/GitHub/exynos990/kout"
export AK3="/home/chanz/Documentos/GitHub/exynos990/AnyKernel3"

export PLATFORM_VERSION=11
export ANDROID_MAJOR_VERSION=r 
export ARCH=arm64
export SEC_BUILD_CONF_VENDOR_BUILD_OS=13

DATE_START=$(date +"%s")

make O="$OUT_DIR" chanz_c1s_defconfig
make O="$OUT_DIR" -j12 2>&1 | tee "../$LOG_FILE"

cd /home/chanz/Documentos/GitHub/exynos990/toolchain/

./mkdtimg cfg_create "$AK3"/dtb.img $(pwd)/dtconfigs/exynos9830.cfg -d "$OUT_DIR"/arch/arm64/boot/dts/exynos
./mkdtimg cfg_create "$AK3"/dtbo.img $(pwd)/dtconfigs/c1s.cfg -d "$OUT_DIR"/arch/arm64/boot/dts/samsung

cd /home/chanz/Documentos/GitHub/exynos990/

IMAGE="$OUT_DIR/arch/arm64/boot/Image"

if [[ -f "$IMAGE" ]]; then
    KERNELZIP="PuppyKernel-v1.1.zip"

    mv "$OUT_DIR"/arch/arm64/boot/Image "$AK3"/Image
    # Create the AnyKernel package
    (cd "AnyKernel3" && zip -r9 "$KERNELZIP" .) || error_exit "Error creating the AnyKernel package"

    DATE_END=$(date +"%s")
    DIFF=$(($DATE_END - $DATE_START))

    echo -e "\nCompilation completed successfully. Elapsed time: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.\n"
fi

if [ -d "kout" ]; then
    rm -r "kout"
    echo "directory removed.."
else
    echo "pff. There is no 'kout' directory."
fi
