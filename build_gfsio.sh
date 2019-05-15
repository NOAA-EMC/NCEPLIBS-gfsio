#!/bin/sh

 (( $# == 0 )) && {
   echo "*** Usage: $0 wcoss|dell|cray|theia|intel_general|gnu_general [debug|build] [[local]install[only]]"
   exit 1
 }

 sys=${1,,}
 [[ $sys == wcoss || $sys == dell || $sys == cray ||\
    $sys == theia || $sys == intel_general || $sys == gnu_general ]] || {
   echo "*** Usage: $0 wcoss|dell|cray|theia|intel_general|gnu_general [debug|build] [[local]install[only]]"
   exit 1
 }
 debg=false
 inst=false
 skip=false
 local=false
 (( $# > 1 )) && {
   [[ ${2,,} == build ]] && debg=false
   [[ ${2,,} == debug ]] && debg=true
   [[ ${2,,} == install ]] && inst=true
   [[ ${2,,} == localinstall ]] && { local=true; inst=true; }
   [[ ${2,,} == installonly ]] && { inst=true; skip=true; }
   [[ ${2,,} == localinstallonly ]] && { local=true; inst=true; skip=true; }
 }
 (( $# > 2 )) && {
   [[ ${3,,} == build ]] && debg=false
   [[ ${3,,} == debug ]] && debg=true
   [[ ${3,,} == install ]] && inst=true
   [[ ${3,,} == localinstall ]] && { local=true; inst=true; }
   [[ ${3,,} == installonly ]] && { inst=true; skip=true; }
   [[ ${3,,} == localinstallonly ]] && { local=true; inst=true; skip=true; }
 }

 source ./Conf/Collect_info.sh
 source ./Conf/Gen_cfunction.sh
 source ./Conf/Reset_version.sh

 if [[ ${sys} == "intel_general" ]]; then
   sys6=${sys:6}
   source ./Conf/Gfsio_${sys:0:5}_${sys6^}.sh
 elif [[ ${sys} == "gnu_general" ]]; then
   sys4=${sys:4}
   source ./Conf/Gfsio_${sys:0:3}_${sys4^}.sh
 else
   source ./Conf/Gfsio_intel_${sys^}.sh
 fi
 [[ -z $GFSIO_VER || -z $GFSIO_LIB4 ]] && {
   echo "??? GFSIO: module/environment not set."
   exit 1
 }

set -x
 gfsioLib4=$(basename ${GFSIO_LIB4})
 gfsioInc4=$(basename ${GFSIO_INC4})

#################
 cd src
#################

 $skip || {
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
 }

 $inst && {
#
#     Install libraries and source files
#
   $local && {
              LIB_DIR4=..
              INCP_DIR4=..
              SRC_DIR=
             } || {
              LIB_DIR4=$(dirname $GFSIO_LIB4)
              INCP_DIR4=$(dirname $GFSIO_INC4)
              SRC_DIR=$GFSIO_SRC
              [ -d $LIB_DIR4 ] || mkdir -p $LIB_DIR4
              [ -d $GFSIO_INC4 ] && { rm -rf $GFSIO_INC4; } \
                                 || { mkdir -p $INCP_DIR4; }
              [ -z $SRC_DIR ] || { [ -d $SRC_DIR ] || mkdir -p $SRC_DIR; }
             }

   make clean LIB=
   make install LIB=$gfsioLib4 MOD=$gfsioInc4 \
                LIB_DIR=$LIB_DIR4 INC_DIR=$INCP_DIR4 SRC_DIR=$SRC_DIR
 }

