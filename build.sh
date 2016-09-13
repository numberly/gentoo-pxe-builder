#!/bin/bash

# defaults
ARCH=${ARCH:-amd64}
MIRROR=${MIRROR:-http://distfiles.gentoo.org}
SSH_KEY_PATH=${SSH_KEY_PATH:-~/.ssh/id_rsa.pub}

die(){ echo "$@" 1>&2; exit 1; }

mkdir -p iso
pushd iso
	base_url="${MIRROR}/releases/${ARCH}/autobuilds"

	latest_iso=$(curl "${base_url}/latest-iso.txt" 2>/dev/null | grep '\-minimal\-' | cut -d " " -f 1 | head -1)
	iso=$(basename "${latest_iso}")

	wget -nc "${base_url}/${latest_iso}" || die "Could not download iso"
	wget -nc "${base_url}/${latest_iso}.DIGESTS.asc" || die "Could not download digests"
	wget -nc "${base_url}/${latest_iso}.CONTENTS" || die "Could not download contents"
	sha512_digests=$(grep -A1 SHA512 "${iso}.DIGESTS.asc" | grep -v '^--')
	gpg --verify "${iso}.DIGESTS.asc" || die "Insecure digests"
	echo "${sha512_digests}" | sha512sum -c || die "Checksum validation failed"
popd
mkdir mnt
sudo mount -o loop iso/${iso} mnt/

cp mnt/isolinux/gentoo .

mkdir squashmnt squash
sudo mount -t squashfs -o loop mnt/image.squashfs squashmnt/
sudo cp -a squashmnt/* squash/
sudo umount squashmnt/ && rmdir squashmnt

sudo cp files/setup.start squash/etc/local.d/
sudo chmod +x squash/etc/local.d/setup.start

sudo mkdir -p squash/root/.ssh
if [ -f "${SSH_KEY_PATH}" ]; then
	sudo cp "${SSH_KEY_PATH}" squash/root/.ssh/authorized_keys
	sudo chmod 600 squash/root/.ssh/authorized_keys
fi

sudo mksquashfs squash/ image.squashfs
sudo rm -rf squash

mkdir igz
pushd igz
	xzcat ../mnt/isolinux/gentoo.igz | sudo cpio -idv &>/dev/null

	patch < ../files/init.livecd.patch

	sudo mkdir -p mnt/cdrom
	sudo mv ../image.squashfs mnt/cdrom/

	find . -print | cpio -o -H newc | gzip -9 -c - > ../gentoo.igz
popd

sudo rm -rf igz
sudo umount mnt && rmdir mnt

clear
echo "All done:"
echo "---------"
echo "  - PXE kernel file : gentoo"
echo "  - PXE initramfs file : gentoo.igz"
