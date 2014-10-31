#!/bin/sh
HELP=0
SOURCE=''
OUTPUT='sa.out'
LANG=''
COMPILER='env gcc'
CC='env gcc48'
USE_CC=0
CPP='env g++48'
USE_CPP=0
AWK='env awk -f'
USE_AWK=0
PERL='env prel'
USE_PERL=0
PYTHON2='env python'
USE_PYTHON2=0
PYTHON3='env python3'
USE_PYTHON3=0
RUBY='env ruby'
USE_RUBY=0
HASKELL='env ghc'
USE_HASKELL=0
LUA='env lu52'
USE_LUA=0
BASH='env sh'
USE_BASH=0
Usage(){
    echo "usage: polyglot.sh [-h] -s SOURCEFILE [-o OUTPUTFILE] -l LANGUAGE [-c COMPILER]"
    echo "-h: show this usage"
    echo "-s: source file name"
    echo "-o: output file name (default is sa.out)"
    echo "-l: select lanugage (seperate by ,)"
    echo "-c: select C/C++ compiler (default is gcc/g++)"
}

while getopts hl:s:o:c: op ; do
    echo "${OPTIND}-th arg ${op}"
    case $op in 
	h)
	    HELP=1;;
	s)
	    SOURCE=${OPTARG};;
	o)
	    OUTPUT=${OPTARG};;
	l)
	    LANG=${OPTARG};;
	c)
	    COMPILER=${OPTARG};;
	*)
	    echo "defualt";;
    esac
done
echo "${HELP} ${SOURCE} ${OUTPUT} ${LANG} ${COMPILER}"
if [ ${#LANG} -eq 0 ] ; then
    echo "No target"
fi
if [ ${#SOURCE} -eq 0 ] ; then
    echo "Source file name cannot be empty"
fi
if ! [ -e ${SOURCE} ] ; then
    echo "Source file '${SOURCE}' doesn't exist"
fi
IFS=","
for lang in ${LANG} ; do
    if [ ${lang} = "g" ] ; then
	echo "yeap"
    fi
    echo ${lang}
done
Usage
