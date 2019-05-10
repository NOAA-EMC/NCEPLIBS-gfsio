# *** manually set environments (for gnu compiler) of gfsio ***

# !!! module environment (*THEIA*) !!!
#module load gcc/6.2.0   # use default GCC comiler for compatible to w3emc

 ANCHORDIR=..
 export COMP=gnu
 export GFSIO_VER=v1.1.0
 export GFSIO_SRC=
 export GFSIO_INC4=$ANCHORDIR/include/gfsio_${GFSIO_VER}_4
 export GFSIO_LIB4=$ANCHORDIR/libgfsio_${GFSIO_VER}_4.a

 export CC=gcc
 export FC=gfortran
 export CPP=cpp
 export OMPCC="$CC -fopenmp"
 export OMPFC="$FC -fopenmp"
 export MPICC=mpigcc
 export MPIFC=mpigfortran

 export DEBUG="-g -O0"
 export CFLAGS="-O3 -fPIC"
 export FFLAGS="-O3 -fconvert=big-endian -fimplicit-none -fno-second-underscore -frecord-marker=4 -funroll-loops -Wall -fPIC"
 export FREEFORM="-ffree-form"
 export FPPCPP="-cpp"
 export CPPFLAGS="-P -traditional-cpp"
 export MPICFLAGS="-O3 -fPIC"
 export MPIFFLAGS="-O3 -fPIC"
 export MODPATH="-J"
 export I4R4=""
 export I4R8="-fdefault-real-8"
 export I8R8="-fdefault-integer-8 -fdefault-real-8"

 export CPPDEFS=""
 export CFLAGSDEFS="-DUNDERSCORE -DLINUX"
 export FFLAGSDEFS=""

 export USECC=""
 export USEFC="YES"
 export DEPS=""
