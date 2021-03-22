#!/bin/bash
# Display a list of required DLLs for a specific exe.

FILE=$1

if [ -f "${FILE}" ]; then
	x86_64-w64-mingw32-objdump -p ${FILE} | grep 'DLL Name:' | sed -e "s/\t*DLL Name: //g"
else
	if [ -z "$1" ]; then
		printf "\nFindDLL - Usage:\nfinddll [Windows executable]\n\n"
	else
		echo "The file ${FILE} does not exist in the current directory."
	fi
fi

