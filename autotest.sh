#!/bin/sh

RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
RESET_COLOR="\033[0m"

QNAME="1521 ass1"
BIN_C="./cellular"
BIN_S="1521 spim -f cellular.s"

echo "Compiling..."
make || exit 1
echo

if [ ! -f "$BIN_C" ]
then
	echo "No such executable: $BIN_C"
	exit 1
fi

if [ ! -x "$BIN_C" ]
then
	echo "$BIN_C is not executable"
	exit 1
fi

if [ ! -f "cellular.s" ]
then
	echo "No such file: cellular.s"
	exit 1
fi

if [ ! -d tests ]
then
	echo "Missing tests directory"
	exit 1
fi

if [ "$#" -eq 0 ]
then
	inFiles="tests/*.in"
elif [ "$#" -eq 1 ]
then
	inFiles="empty"
else
	echo "Usage-1: autotest  "
	echo "Usage-2: autotest <test-number> "
	exit 1
fi

echo "***  Testing $QNAME  ***"
echo

for tt in $inFiles
do
    t=`basename $tt`
	t="${t%.*}"
	$BIN_C < tests/$t.in > tests/$t.exp
	$BIN_S < tests/$t.in | echo "$(tail -n +1 tests/$t.exp)" > tests/$t.out
	echo "------------------------------ "
	if diff tests/$t.exp tests/$t.out > /dev/null
    then
        printf "${GREEN}Test $t passed\n$RESET_COLOR"
    else
        printf "${RED}Test $t failed\n$RESET_COLOR"
        printf "${YELLOW}Check differences between tests/$t.exp and tests/$t.out\n$RESET_COLOR"
    fi
	echo "------------------------------ "
done
