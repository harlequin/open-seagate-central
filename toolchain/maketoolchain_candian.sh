#!/bin/bash
#
# maketoolchain
#
# Script to build GCC toolchain for Seagate Central NAS
# using open source code.
#
# Supply optional arguments 0 to disable various build stages.
#

. toolchain_config.sh


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

##############################################################################
# Canadian build - needed for windows
##############################################################################
#if [[ $ENABLE_CANADIAN_BUILD != 0 ]]; then


if [[ $1 != 0 ]]; then
  echo "[x] generate canadian build for $CANADIAN_HOST ..."
  echo "[x] building binutils"
  mkdir -p $OBJ/$CANADIAN_HOST-binutils
  cd $OBJ/$CANADIAN_HOST-binutils

  $SRC/$binutilsv/configure --target=$TARGET --host=$CANADIAN_HOST \
      --build=$build --prefix=$TOOLS --with-sysroot=$TARGET \
      --disable-werror &> $TOP/config_binutils.log
  checkerr $? "[-] config binutils" $TOP/config_binutils.log

  make -j8 &> $TOP/make_binutils.log
  checkerr $? "[-] make binutils" $TOP/make_binutils.log

  make install &> $TOP/make_binutils_install.log
  checkerr $? "[-] install binutils" $TOP/make_binutils_install.log	
fi

if [[ $2 != 0 ]]; then
  mkdir -p $OBJ/gmp
  cd $OBJ/gmp
  $SRC/gmp-6.1.2/configure --disable-shared --enable-static  \
      --host=$CANADIAN_HOST --build=$build --prefix=$OBJ/gmp \
  &> $TOP/config_gmp.log
  checkerr $? "config gmp" $TOP/config_gmp.log

  make -j4 &> $TOP/make_gmp.log
  checkerr $? "make gmp" $TOP/make_gmp.log

  make install &> $TOP/make_gmp_install.log
  checkerr $? "install gmp" $TOP/make_gmp_install.log	

  mkdir -p $OBJ/mpfr
  cd $OBJ/mpfr
  $SRC/mpfr-3.1.5/configure --disable-shared --enable-static \
      --host=$CANADIAN_HOST --build=$build --prefix=$OBJ/mpfr \
      --with-gmp=$OBJ/gmp &> $TOP/config_mpfr.log
  checkerr $? "config mpfr" $TOP/config_mpfr.log

  make -j4 &> $TOP/make_mpfr.log
  checkerr $? "make mpfr" $TOP/make_mpfr.log
  
  make install &> $TOP/make_mpfr_install.log
  checkerr $? "install mpfr" $TOP/make_mpfr_install.log	

  mkdir -p $OBJ/mpc
  cd $OBJ/mpc
  $SRC/mpc-1.0.3/configure \
      --host=$CANADIAN_HOST --build=$build --prefix=$OBJ/mpc \
      --with-gmp=$OBJ/gmp --with-mpfr=$OBJ/mpfr --enable-static --disable-shared &> $TOP/config_mpc.log
  checkerr $? "config mpc" $TOP/config_mpc.log

  make -j4 &> $TOP/make_mpc.log
  checkerr $? "make mpc" $TOP/make_mpc.log
  
  make install &> $TOP/make_mpc_install.log
  checkerr $? "install mpc" $TOP/make_mpc_install.log	
fi

if [[ $3 != 0 ]]; then
  mkdir -p $OBJ/gcc4
  cd $OBJ/gcc4
# 
  $SRC/$gccv/configure \
      --target=$TARGET --host=$CANADIAN_HOST --build=$build \
      --prefix=$TOOLS --disable-libstdcxx-pch\
      --with-sysroot=$SYSROOT \
      --enable-__cxa_atexit \
      --disable-libssp --disable-libgomp --disable-libmudflap \
      --enable-languages=c,c++ --with-gmp=$OBJ/gmp --with-mpc=$OBJ/mpc --with-mpfr=$OBJ/mpfr --enable-threads=posix \
  &> $TOP/config_gcc4.log
  checkerr $? "config 4rd (final) GCC" $TOP/config_gcc4.log

  make -j4 &> $TOP/make_gcc4.log
  checkerr $? "make 4rd (final) GCC" $TOP/make_gcc4.log

  make install &> $TOP/make_gcc4_install.log
  checkerr $? "install 4rd (final) GCC" $TOP/make_gcc4_install.log
fi

#fi
