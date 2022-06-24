sudo truncate -s 2G image.raw
sudo sgdisk -g --clear -a 1 \
  --new=1:34:2081:       --change-name=1:spl    --typecode=1:5B193300-FC78-40CD-8002-E86C45580B47 \
  --new=2:2082:16383:    --change-name=2:uboot  --typecode=2:2E54B353-1271-4842-806F-E436D6AF6985 \
  --new=3:16384:-0       --change-name=3:rootfs --attributes=3:set:2  \
  image.raw
dd if=$PWD/repos/u-boot/spl/u-boot-spl.bin of=image.raw bs=512 seek=34 conv=sync,notrunc
dd if=$PWD/repos/u-boot/u-boot.itb of=image.raw bs=512 seek=2082 conv=sync,notrunc
sudo losetup -D
sudo losetup -f -P image.raw
sudo mkfs.ext4 /dev/loop0p3
sudo e2label /dev/loop0p3 rootfs
sudo mkdir rootfs
sudo mount /dev/loop0p3 rootfs/
sudo pacstrap rootfs base dracut-hook linux
sudo mkdir rootfs/boot/extlinux
tee -a rootfs/boot/extlinux/extlinux.conf << END
default arch
menu title U-Boot menu
prompt 0
timeout 50

label arch
        menu label Arch Linux
        linux /boot/vmlinuz-linux
        initrd /boot/initramfs-linux.img
        fdtdir /boot/dtbs/
        append root=LABEL="rootfs" rw earlycon
END
sudo cp -r rootfs/usr/share/dtbs/*-arch*/ rootfs/boot/dtbs
sudo umount -l rootfs
sudo rmdir rootfs
sudo losetup -D
