#!/bin/bash

# Проверка параметров
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <original_iso_path> <new_iso_path>"
    exit 1
fi

# Аргументы командной строки
ORIG_ISO=$1
NEW_ISO=$2

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
mkisofs \
  -o $NEW_ISO \
  -b isolinux/isolinux.bin \
  -J -R -l -v -T \
  -c isolinux/boot.cat \
  -no-emul-boot \
  -boot-load-size 4 \
  -boot-info-table \
  -eltorito-alt-boot \
  -e boot/grub/efi.img \
  -no-emul-boot \
  -V "DEB11-PR1" \
  -A "DEB11-PR1" \
  -joliet-long \
  $ISO_EXTRACT_DIR

# Постобработка
isohybrid --uefi $NEW_ISO
implantisomd5 $NEW_ISO

# Очистка временных файлов
rm -rf $WORK_DIR

# Завершение скрипта
echo "Новый ISO-образ создан: $NEW_ISO"
exit 0
