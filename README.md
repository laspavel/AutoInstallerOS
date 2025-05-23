# AutoInstallerOS

Silent installation RPM (Oracle Linux 8-9), (Debian 11-12) and Ubuntu 24 Server OS.

## Installation

1) Clone this repository.
2) Install the necessary dependencies:

For Deb:
```
sudo apt -y install rsync sysutils sysutils-tools isomd5sum mkisofs xorriso
```

For RPM:
```
sudo dnf -y install rsync syslinux isomd5sum mkisofs xorriso
```

For scripts to work correctly, the user must have mount (or sudo) execution rights.

## Usage

Usage examples: 
```
# For Oracle Linux
./create_custom_iso.sh OracleLinux-R8-U10-x86_64-dvd.iso OL8.iso

# For Debian
./create_custom_iso.sh debian-12.5.0-amd64-DVD-1.iso Deb12.iso

```

Here:
* OracleLinux-R8-U10-x86_64-dvd.iso,debian-12.5.0-amd64-DVD-1.iso - the source image from which the build is carried out

* OL8.iso, Deb12.iso - the name of the resulting image

Additional files that participate in the assembly (grub.cfg, isolinux.cfg etc.) of the required version are located in the target folders.

## License ##

MIT / BSD

---
* [https://pykickstart.readthedocs.io/en/latest/kickstart-docs.html](https://pykickstart.readthedocs.io/en/latest/kickstart-docs.html)
* [https://anaconda-installer.readthedocs.io/en/latest/boot-options.html](https://anaconda-installer.readthedocs.io/en/latest/boot-options.html)
* [https://www.debian.org/releases/stable/amd64/apbs04.ru.html](https://www.debian.org/releases/stable/amd64/apbs04.ru.html)
* [https://unix.stackexchange.com/questions/640232/verified-good-mkisofs-for-centos-8](https://unix.stackexchange.com/questions/640232/verified-good-mkisofs-for-centos-8)
* [https://github.com/dafydd2277/systemAdmin/tree/main/kickstart/centos8](https://github.com/dafydd2277/systemAdmin/tree/main/kickstart/centos8)
* [https://access.redhat.com/discussions/6161602](https://access.redhat.com/discussions/6161602)
* [https://github.com/iwDevOps/RockyLinux8-Kickstart-iso](https://github.com/iwDevOps/RockyLinux8-Kickstart-iso)
* [https://canonical-subiquity.readthedocs-hosted.com/en/latest/reference/autoinstall-reference.html#storage](https://canonical-subiquity.readthedocs-hosted.com/en/latest/reference/autoinstall-reference.html#storage)
* [https://curtin.readthedocs.io/en/latest/topics/storage.html](https://curtin.readthedocs.io/en/latest/topics/storage.html)
* [https://curtin.readthedocs.io/en/latest/topics/config.html#grub](https://curtin.readthedocs.io/en/latest/topics/config.html#grub)
* [https://askubuntu.com/questions/1487504/ubuntu-22-04-autoinstall-works-on-uefi-but-not-mbr-in-virtualbox](https://askubuntu.com/questions/1487504/ubuntu-22-04-autoinstall-works-on-uefi-but-not-mbr-in-virtualbox)



