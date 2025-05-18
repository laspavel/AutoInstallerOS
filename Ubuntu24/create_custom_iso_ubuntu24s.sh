#!/bin/bash

# Проверка параметров
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <original_iso_path> <new_iso_path>"
    exit 1
fi

# Аргументы командной строки
ORIG_ISO=$1
NEW_ISO=$2
today=$(date +"%Y-%m-%d")

# dnf install xorriso
# apt install xorriso

mkdir -p tmp
WORK_DIR=$(mktemp -d -p tmp)
ISO_MOUNT_DIR="$WORK_DIR/iso"
ISO_EXTRACT_DIR="$WORK_DIR/extract"
mkdir -p $ISO_MOUNT_DIR $ISO_EXTRACT_DIR

# Монтирование оригинального ISO-образа
mount -o loop $ORIG_ISO $ISO_MOUNT_DIR

# Копирование содержимого ISO-образа в рабочий каталог
rsync -av $ISO_MOUNT_DIR/. $ISO_EXTRACT_DIR/

# Размонтирование ISO-образа
umount $ISO_MOUNT_DIR

mkdir -p $ISO_EXTRACT_DIR/nocloud_mbr
mkdir -p $ISO_EXTRACT_DIR/nocloud_efi
cp -f user-data_mbr $ISO_EXTRACT_DIR/nocloud_mbr/user-data
touch $ISO_EXTRACT_DIR/nocloud_mbr/meta-data
cp -f user-data_efi $ISO_EXTRACT_DIR/nocloud_efi/user-data
touch $ISO_EXTRACT_DIR/nocloud_efi/meta-data

cp -f grub.cfg $ISO_EXTRACT_DIR/boot/grub/

#
# Вот эти страшные параметры определяются командой:
# xorriso -indev ubuntu-24.04.1-live-server-amd64.iso -report_el_torito as_mkisofs
#

xorriso -as mkisofs \
-V 'U24S-SI1' \
--grub2-mbr --interval:local_fs:0s-15s:zero_mbrpt,zero_gpt:$ORIG_ISO \
--protective-msdos-label \
-partition_cyl_align off \
-partition_offset 16 \
--mbr-force-bootable \
-append_partition 2 28732ac11ff8d211ba4b00a0c93ec93b --interval:local_fs:6264708d-6274851d::$ORIG_ISO \
-appended_part_as_gpt \
-iso_mbr_part_type a2a0d0ebe5b9334487c068b6b72699c7 \
-c '/boot.catalog' \
-b '/boot/grub/i386-pc/eltorito.img' \
-no-emul-boot \
-boot-load-size 4 \
-boot-info-table \
--grub2-boot-info \
-eltorito-alt-boot \
-e '--interval:appended_partition_2_start_1566177s_size_10144d:all::' \
-no-emul-boot \
-boot-load-size 10144 \
-o $NEW_ISO \
$ISO_EXTRACT_DIR

# Очистка временных файлов
rm -rf $WORK_DIR

# Завершение скрипта
echo "Новый ISO-образ создан: $NEW_ISO"
exit 0
