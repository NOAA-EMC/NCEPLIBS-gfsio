#!/bin/sh

 : ${THISDIR:=$(dirname $(readlink -f -n ${BASH_SOURCE[0]}))}
 CDIR=$PWD; cd $THISDIR

 source ./Conf/Analyse_args.sh
 source ./Conf/Collect_info.sh
 source ./Conf/Gen_cfunction.sh
 source ./Conf/Reset_version.sh

 if [[ ${sys} == "intel_general" ]]; then
   sys6=${sys:6}
   source ./Conf/Gfsio_${sys:0:5}_${sys6^}.sh
   rinst=false
 elif [[ ${sys} == "gnu_general" ]]; then
   sys4=${sys:4}
   source ./Conf/Gfsio_${sys:0:3}_${sys4^}.sh
   rinst=false
 else
   source ./Conf/Gfsio_intel_${sys^}.sh
 fi
 $CC --version &> /dev/null || {
   echo "??? GFSIO: compilers not set." >&2
   exit 1
 }
 [[ -z ${GFSIO_VER+x} || -z ${GFSIO_LIB4+x} ]] && {
   [[ -z ${libver+x} || -z ${libver} ]] && {
     echo "??? GFSIO: \"libver\" not set." >&2
     exit
   }
   GFSIO_INC4=${libver}_4
   GFSIO_LIB4=lib${libver}_4.a
   GFSIO_VER=v${libver##*_v}
 }

set -x
 gfsioLib4=$(basename ${GFSIO_LIB4})
 gfsioInc4=$(basename ${GFSIO_INC4})

#################
 cd src
#################

#-------------------------------------------------------------------
# Start building libraries
#
 echo
 echo "   ... build default (i4/r4) gfsio library ..."
 echo
  make clean LIB=$gfsioLib4 MOD=$gfsioInc4
   mkdir -p $gfsioInc4
   FFLAGS4="$I4R4 $FFLAGS ${MODPATH}$gfsioInc4"
   collect_info gfsio 4 OneLine4 LibInfo4
   gfsioInfo4=gfsio_info_and_log4.txt
   $debg && make debug FFLAGS="$FFLAGS4" LIB=$gfsioLib4 \
                                         &> $gfsioInfo4 \
         || make build FFLAGS="$FFLAGS4" LIB=$gfsioLib4 \
                                         &> $gfsioInfo4
   make message MSGSRC="$(gen_cfunction $gfsioInfo4 OneLine4 LibInfo4)" \
                LIB=$gfsioLib4

 $inst && {
#
#     Install libraries and source files
#
   $local && {
     instloc=..
     LIB_DIR=$instloc/lib
     INCP_DIR=$instloc/include
     [ -d $LIB_DIR ] || { mkdir -p $LIB_DIR; }
     [ -d $INCP_DIR ] || { mkdir -p $INCP_DIR; }
     LIB_DIR4=$LIB_DIR
     INCP_DIR4=$INCP_DIR
     SRC_DIR=
   } || {
     $rinst && {
       LIB_DIR4=$(dirname $GFSIO_LIB4)
       INCP_DIR4=$(dirname $GFSIO_INC4)
       [ -d $GFSIO_INC4 ] && { rm -rf $GFSIO_INC4; } \
                          || { mkdir -p $INCP_DIR4; }
       SRC_DIR=$GFSIO_SRC
     } || {
       LIB_DIR=$instloc/lib
       LIB_DIR4=$LIB_DIR
       INCP_DIR=$instloc/include
       INCP_DIR4=$INCP_DIR
       GFSIO_INC4=$INCP_DIR4/$GFSIO_INC4
       [ -d $GFSIO_INC4 ] && { rm -rf $GFSIO_INC4; } \
                          || { mkdir -p $INCP_DIR4; }
       SRC_DIR=$instloc/src
       [[ $instloc == .. ]] && SRC_DIR=
     }
     [ -d $LIB_DIR4 ] || mkdir -p $LIB_DIR4
     [ -z $SRC_DIR ] || { [ -d $SRC_DIR ] || mkdir -p $SRC_DIR; }
   }

   make clean LIB=
   make install LIB=$gfsioLib4 MOD=$gfsioInc4 \
                LIB_DIR=$LIB_DIR4 INC_DIR=$INCP_DIR4 SRC_DIR=$SRC_DIR
 }

