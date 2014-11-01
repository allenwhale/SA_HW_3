#!/bin/sh
#!/usr/bin/env gcc48
HELP=0
SOURCE=''
OUTPUT='sa.out'
LANG=''
COMPILER='gcc'
CC='gcc48'
CPP='env g++48'
AWK='env awk -f'
PERL='env perl'
PYTHON2='env python'
PYTHON3='env python3'
RUBY='env ruby'
HASKELL='env ghc'
LUA='env lua52'
BASH='env bash'
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
if [ ${HELP} -eq 1 ] ; then 
    Usage
    exit 0
fi
if [ ${#LANG} -eq 0 ] ; then
    echo "No target"
fi
if [ ${#SOURCE} -eq 0 ] ; then
    echo "Source file name cannot be empty"
fi
if ! [ -e ${SOURCE} ] ; then
    echo "Source file '${SOURCE}' doesn't exist"
fi
if [ ${COMPILER} = "gcc" ] || [ ${COMPILER} = "g++" ] ; then
    C='env gcc48'
    CPP='env g++48'
elif [ ${COMPILER} = "clang" ] || [ ${COMPILER} = "clang++" ] ; then
    C='env clang'
    CPP='env clang++'
elif [ ${#COMPILER} -ne 0 ] ; then
    echo "compiler '${COMPILER}' is unknown"
fi

IFS=","
for lang in ${LANG} ; do
    if [ ${lang} = "c" ] || [ ${lang} = "C" ] ; then
	echo "Run in C"
	eval "${CC} ${SOURCE} -o ${OUTPUT}"
	./${OUTPUT}
	echo "==================================================="
    elif [ ${lang} = "c" ] || [ ${lang} = "cpp" ] || [ ${lang} = "Cpp" ] \
	|| [ ${lang} = "c++" ] || [ ${lang} = "C++" ] ; then 
	echo "Run in C++"
	eval "${CPP} ${SOURCE} -o ${OUTPUT}"
	./${OUTPUT}
	echo "==================================================="
    elif [ ${lang} = "awk" ] || [ ${lang} = "AWK" ] ; then
	echo "Run in Awk"
	eval "${AWK} ${SOURCE}"
	echo "==================================================="
    elif [ ${lang} = "perl" ] || [ ${lang} = "Perl" ] ; then
	echo "Run in Perl"
	eval "${PERL} ${SOURCE}"
	echo "==================================================="
    elif [ ${lang} = "python" ] || [ ${lang} = "Python" ] || [ ${lang} = "py" ] \
	|| [ ${lang} = "python2" ] || [ ${lang} = "Python2" ] || [ ${lang} = "py2" ] ; then
	echo "Run in Python"
	eval "${PYTHON2} ${SOURCE}"
	echo "==================================================="
    elif [ ${lang} = "python3" ] || [ ${lang} = "Python3" ] || [ ${lang} = "py3" ] ; then
	echo "Run in Python2"
	eval "${PYTHON3} ${SOURCE}"
	echo "==================================================="
    elif [ ${lang} = "ruby" ] || [ ${lang} = "Ruby" ] || [ ${lang} = "rb" ] ; then
	echo "Run in Ruby"
	eval "${RUBY} ${SOURCE}"
	echo "==================================================="
    elif [ ${lang} = "Haskell" ] || [ ${lang} = "haskell" ] || [ ${lang} = "hs" ] ; then
	echo "Run in Haskell"
	eval "${HASKELL} -o ${OUTPUT} ${SOURCE}"
	./${OUTPUT}
	echo "==================================================="
    elif [ ${lang} = "lua" ] || [ ${lang} = "Lua" ] ; then
	echo "Run in Lua"
	eval "${LUA} ${SOURCE}"
	echo "==================================================="
    elif [ ${lang} = "bash" ] || [ ${lang} = "Bash" ] ; then
	echo "Run in Bash"
	eval "${BASH} ${SOURCE}"
	echo "==================================================="
    else
	echo "language '${lang}' is undefined"
    fi
done
