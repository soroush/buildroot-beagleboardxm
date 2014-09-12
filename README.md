BeagleBoard xM Buildroot Configuration
============================

[![Build Status](https://travis-ci.org/soroush/buildroot-beagleboardxm.svg)](https://travis-ci.org/soroush/buildroot-beagleboardxm)

This project aims to provide and maintain a minimal [buildroot](http://buildroot.org/) configuration for
the [BeagleBoard-xM](http://beagleboard.org/beagleboard-xm) (single board computer). In order to prepare a configuration to build, run

    $ make beagleboardxm_defconfig

This will copy default configuration which works for BBxM. This configuration is done as minimal as possible.

To build and use the buildroot stuff, do the following:

1. run ``make menuconfig``
2. select the packages you wish to compile
3. run ``make``
4. wait while it compiles
5. Use your shiny new root filesystem. Depending on which sort of
    root filesystem you selected, you may want to loop mount it,
    chroot into it, nfs mount it on your target device, burn it
    to flash, or whatever is appropriate for your target system.

You do not need to be root to build or run buildroot.  Have fun!

Offline build:
==============

In order to do an offline-build (not connected to the net), fetch all
selected source by issuing a

    $ make source

before you disconnect.
If your build-host is never connected, then you have to copy buildroot
and your toplevel .config to a machine that has an internet-connection
and issue "make source" there, then copy the content of your dl/ dir to
the build-host.

Building out-of-tree:
=====================

Buildroot supports building out of tree with a syntax similar
to the Linux kernel. To use it, add O=<directory> to the
make command line, E.G.:

    $ make O=/tmp/build

And all the output files (including .config) will be located under /tmp/build.

More finegrained configuration:
===============================

You can specify a config-file for uClibc:

    $ make UCLIBC_CONFIG_FILE=/my/uClibc.config

And you can specify a config-file for busybox:

    $ make BUSYBOX_CONFIG_FILE=/my/busybox.config

To use a non-standard host-compiler (if you do not have 'gcc'),
make sure that the compiler is in your PATH and that the library paths are
setup properly, if your compiler is built dynamically:

    $ make HOSTCC=gcc-4.3.orig HOSTCXX=gcc-4.3-mine

Depending on your configuration, there are some targets you can use to
use menuconfig of certain packages. This includes:

    $ make HOSTCC=gcc-4.3 linux-menuconfig
    $ make HOSTCC=gcc-4.3 uclibc-menuconfig
    $ make HOSTCC=gcc-4.3 busybox-menuconfig

Please feed suggestions, bug reports, insults, and bribes to the [issues](https://github.com/soroush/buildroot-beagleboardxm/issues) page in github project.  
