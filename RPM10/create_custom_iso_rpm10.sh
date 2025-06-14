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
cp "ks.cfg" $ISO_EXTRACT_DIR/

# Редактирование конфигурации загрузчика
ISOLINUX_CFG="$ISO_EXTRACT_DIR/isolinux/isolinux.cfg"
GRUB_CFG="$ISO_EXTRACT_DIR/EFI/BOOT/grub.cfg"

# Копирование новой конфигурации загрузчика
cp -f "isolinux.cfg" $ISOLINUX_CFG
cp -f "grub.cfg" $GRUB_CFG

find $ISO_EXTRACT_DIR -name TRANS.TBL -exec rm -f '{}' \;

# Создание нового ISO-образа
xorriso -as mkisofs \
-V 'RPM10-KS1' \
--grub2-mbr --interval:local_fs:0s-15s:zero_mbrpt,zero_gpt:"$ORIG_ISO" \
--protective-msdos-label \
-partition_cyl_align off \
-partition_offset 16 \
-append_partition 2 28732ac11ff8d211ba4b00a0c93ec93b --interval:local_fs:3423312d-3440295d::"$ORIG_ISO" \
-appended_part_as_gpt \
-iso_mbr_part_type a2a0d0ebe5b9334487c068b6b72699c7 \
--boot-catalog-hide \
-b '/images/eltorito.img' \
-no-emul-boot \
-boot-load-size 4 \
-boot-info-table \
--grub2-boot-info \
-eltorito-alt-boot \
-e '--interval:appended_partition_2_start_855828s_size_16984d:all::' \
-no-emul-boot \
-boot-load-size 16984 \
-o $NEW_ISO \
$ISO_EXTRACT_DIR

# Очистка временных файлов
rm -rf $WORK_DIR

# Завершение скрипта
echo "Новый ISO-образ создан: $NEW_ISO"
exit 0
