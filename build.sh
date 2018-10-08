#!/bin/sh
set -eux
#-----------------------------------------------------
cwd=`pwd`
source ../../../machine-setup.sh > /dev/null 2>&1

export LIBNAME=gfsio
export VER=v1.1.0
export FCMP=ifort

if [ $target = wcoss_cray ]; then
  export FCMP=ftn
  module load PrgEnv-intel
  module load craype-sandybridge
elif [ $target = "wcoss" ]; then
  module load ics/12.1
elif [ $target = "theia" ]; then
  module load intel/14.0.2
elif [ $target = "gaea" ]; then
  :
elif [ $target = "jet" ]; then
  module load intel/12.1.4
fi

rm -rf ../../libs/${LIBNAME}_${VER}/libgfsio_v1.1.0_4.a ../../incmod/gfsio_v1.1.0_4 ../../modulefiles/gfsio/v1.1.0

make

mkdir -p ../../libs/${LIBNAME}_${VER}
mv ../../libgfsio_v1.1.0_4.a ../../libs/${LIBNAME}_${VER}/libgfsio_v1.1.0_4.a

#
#     Create modulefile
#
cd ../../
lwd=`pwd`
cd $cwd
mkdir -p $lwd/modulefiles/$LIBNAME
cat modulefile.template | sed s:_CWD_:$lwd:g > $lwd/modulefiles/$LIBNAME/$VER

exit
