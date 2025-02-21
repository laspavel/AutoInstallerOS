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

# Создание рабочего каталога
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

# Копирование файла Kickstart в корень нового ISO
cp "preseed.cfg" $ISO_EXTRACT_DIR/

# Редактирование конфигурации загрузчика
ISOLINUX_CFG="$ISO_EXTRACT_DIR/isolinux/txt.cfg"
GRUB_CFG="$ISO_EXTRACT_DIR/boot/grub/grub.cfg"

# Копирование новой конфигурации загрузчика
cp -f "txt.cfg" $ISOLINUX_CFG
cp -f "grub.cfg" $GRUB_CFG

find $ISO_EXTRACT_DIR -name TRANS.TBL -exec rm -f '{}' \;

# Создание нового ISO-образа с опцией -joliet-long
xorriso -as mkisofs \
-V 'DEB12-PR1' \
-isohybrid-mbr --interval:local_fs:0s-15s:zero_mbrpt,zero_gpt,zero_apm:$ORIG_ISO \
-partition_cyl_align on \
-partition_offset 0 \
-partition_hd_cyl 238 \
-partition_sec_hd 32 \
--mbr-force-bootable \
-apm-block-size 2048 \
-iso_mbr_part_type 0x00 \
-c '/isolinux/boot.cat' \
-b '/isolinux/isolinux.bin' \
-no-emul-boot \
-boot-load-size 4 \
-boot-info-table \
-eltorito-alt-boot \
-e '/boot/grub/efi.img' \
-no-emul-boot \
-boot-load-size 19040 \
-isohybrid-gpt-basdat \
-isohybrid-apm-hfsplus \
-o $NEW_ISO \
$ISO_EXTRACT_DIR

# Очистка временных файлов
rm -rf $WORK_DIR

# Завершение скрипта
echo "Новый ISO-образ создан: $NEW_ISO"
exit 0
