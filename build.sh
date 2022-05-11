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
	wget -nc "${base_url}/${latest_iso}.CONTENTS.gz" || die "Could not download contents"
	sha512_digests=$(grep -A1 SHA512 "${iso}.DIGESTS.asc" | grep -v '^--')
	gpg --verify "${iso}.DIGESTS.asc" || die "Insecure digests"
	echo "${sha512_digests}" | sha512sum -c || die "Checksum validation failed"
popd
iso=iso/${iso}
isoinfo -R -i ${iso} -X -find -path /boot/gentoo && mv -vf boot/gentoo .
isoinfo -R -i ${iso} -X -find -path /image.squashfs
isoinfo -R -i ${iso} -X -find -path /boot/gentoo.igz
(cat boot/gentoo.igz; (echo image.squashfs | cpio -H newc -o)) > gentoo.igz
rm image.squashfs
rm boot/gentoo.igz
rmdir boot

[ -f "${SSH_KEY_PATH}" ] && cp "${SSH_KEY_PATH}" files/authorized_keys
# append cdupdate.sh that do the online modification and other needed files
pushd files
	chmod a+x cdupdate.sh
	find . -print | cpio -H newc -o | xz --check=crc32 -vT0 >> ../gentoo.igz
	[ -f authorized_keys ] && rm authorized_keys
popd

echo "All done:"
echo "---------"
echo "  - PXE kernel file : gentoo"
echo "  - PXE initramfs file : gentoo.igz"
