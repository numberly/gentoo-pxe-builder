gentoo-pxe-builder
==================

## Purpose
The purpose of this PXE builder is to let you boot a machine from PXE and then automatically set it up so you can access it remotely using SSH.

Booting this PXE initramfs will display informations about the network interfaces available on the PXE host so that you don't need to type any sort of command to connect to it.

## What it does for you
This automation script prepares a Gentoo kernel and initramfs suitable to boot from PXE:
* It bases itself from the latest minimal ISO available
* It will **setup a root password and start the SSH daemon**

It lets you take control of the PXE host easily:
* **You can change the files/setup.start script** to adjust your needs at boot and rebuild the whole PXE stack by simply re-runing the build.sh script
* Your SSH public key will already be present on the machine so you can connect without password to your PXE host

## What will happen when I boot ?
* At first this will start your machine just like a simple livecd
* Then it will start waiting for connectivity and display the current IP of your network cards
* As soon as one gets an IP address, it will setup the root password and start the SSH daemon
* Finally, it will discover and display for you the real name of the network interfaces detected on the host based on udev deterministic naming

## Usage
* Modify the `files/setup.start` to match any specific need other than those already prepared for you
* Then just execute the `build.sh` script and enjoy.

## Prerequisites

* The `cpio` command from `app-arch/cpio`
* The `gpg` command from `app-crypt/gnupg`
* The `xz` command from `app-arch/xz-utils`
* The `isoinfo` command from `app-cdr/cdrtools`
* You must have imported the 'Gentoo Linux Release Engineering (Automated Weekly Release Key)' GPG public key in your keyring `gpg --locate-key releng@gentoo.org`

## Environment variables and defaults
The default SSH root password is `gentoo-root`. This is the list of accepted environment variables:
* ARCH : `amd64`
* MIRROR : `http://distfiles.gentoo.org`
* SSH_KEY_PATH : `~/.ssh/id_rsa.pub`

## PXE server basic setup
[Setting up a PXE server](http://www.gentoo-wiki.info/HOWTO_Gentoo_Diskless_Install#Server_setup) is quite easy, just remember a few things:
* Suppose we want our PXE root to be located in `/pxe/`
* Install `sys-boot/syslinux` as it contains the necessary files:

```
# cp /usr/share/syslinux/ldlinux.c32 /pxe/
# cp /usr/share/syslinux/pxelinux.0 /pxe/
```

* Create the `/pxe/pxelinux.cfg/` directory
* Create the default PXE boot file `/pxe/pxelinux.cfg/default`:

```
default Gentoo

label Gentoo
kernel /gentoo_pxe/gentoo
append initrd=/gentoo_pxe/gentoo.igz root=/dev/ram0 init=/linuxrc loop=/image.squashfs looptype=squashfs cdroot
```
