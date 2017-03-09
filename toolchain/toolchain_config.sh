#!/bin/bash
#
# maketoolchain
#
# Script to build GCC toolchain for Seagate Central NAS
# using open source code.
#
# Supply optional arguments 0 to disable various build stages.
#
# Tested to work on Linux Mint

ENABLE_CANADIAN_BUILD=0
CANADIAN_HOST=i686-w64-mingw32



build=i686-pc-linux-gnu
host=i686-pc-linux-gnu
export TARGET=arm-seagate-linux-gnueabi
linux_arch=arm
export ARCH=arm
export CROSS_COMPILE=${TARGET}-

# see https://gcc.gnu.org/bugzilla/show_bug.cgi?id=14654
export _POSIX2_VERSION=199209

binutilsv=binutils-2.22
gccv=gcc-4.9.4
linuxv=linux
GLIBC=glibc-2.11-2010q1-mvl6

GMP=gmp-6.1.2
MPC=mpc-1.0.3
MPFR=mpfr-3.1.5



# you can choose different directories here
TOP=$(pwd)/arm-seagate-linux-gnueabi
SRC=$(pwd)/src

OBJ=$TOP/_obj
TOOLS=$TOP

export SYSROOT=$TOP
export PATH=$TOOLS/bin:$PATH

unset LD_LIBRARY_PATH 

mkdir -p $OBJ
mkdir -p $TOOLS
mkdir -p $SYSROOT
#report error.  4 arguments. 
# $1-retval (0 means success)  $2-name $3-log file $4-cont. on fail (optional)
checkerr()
{
  local GRN="\e[32m"
  local RED="\e[31m"
  local YEL="\e[33m"
  local NOCOLOR="\e[0m"

  if [ $1 -ne 0 ]; then
    echo -e "$RED Failure: $2. Check $3 $NOCOLOR"
    tail $3
    if [ ${4-1} -eq 1 ]; then
      echo -e "$YEL           trying to continue $NOCOLOR"
    else
      exit 1
    fi
  else
    echo -e "$GRN Success: $2.$NOCOLOR See $3"
  fi
}


ZIPSRC=seagate-central-firmware-gpl-source-code.zip
if [ ! -d $SRC/$gccv ]; then
   echo "Please copy $gccv to $SRC/$gccv"
   echo "$gccv is included in GPL/gcc/gcc.tar in $ZIPSRC"
   exit 1
fi

if [ ! -d $SRC/$linuxv ]; then
   echo "Please copy $linuxv to $SRC/$linuxv"
   echo "$linuxv is included in GPL/linux/git_<...>.tar.gz in $ZIPSRC"
   exit 1
fi

if [ ! -d $SRC/$GLIBC ]; then
   echo "Please copy $GLIBC to $SRC/$GLIBC"
   echo "$GLIBC is included in LGPL/glibc/glibc.tar in $ZIPSRC"
   exit 1
fi

if [ ! -d $SRC/$GLIBC ]; then
   echo "Please copy $GLIBC to $SRC/$GLIBC"
   echo "$GLIBC is included in LGPL/glibc/glibc.tar in $ZIPSRC"
   exit 1
fi

if [ ! -d $SRC/$GLIBC/ports ]; then
   echo "Please link $SRC/$GLIBC/ports to glibc-ports"
   echo "glibc-ports is included in LGPL/glibc/glibc_ports.tar in $ZIPSRC"
   echo "after extracting glibc_ports.tar to $SRC"
   echo "run"
   echo "ln -s ../glibc-ports-2.11-2010q1-mvl6/ $SRC/$GLIBC/ports"
   exit 1
fi


if [[ $ENABLE_CANADIAN_BUILD != 0 ]]; then
    if [ ! -d $SRC/$GMP ]; then
        echo "Please copy $GMP to $SRC/$GMP"
        exit 1
    fi

    if [ ! -d $SRC/$MPC ]; then
	echo "Please copy $MPC to $SRC/$MPC"
	exit 1
    fi

    if [ ! -d $SRC/$MPFR ]; then
	echo "Please copy $MPFR to $SRC/$MPFR"
	exit 1
    fi
fi

checkerr 0 "precheck complete" "-"
