#!/bin/bash
# Display a list of required DLLs for a specific exe.

FILE=$1

if [ -f "${FILE}" ]; then # Check if the specified executable exists in the user's current directory before proceeding
	x86_64-w64-mingw32-objdump -p ${FILE} | grep 'DLL Name:' | sed -e "s/\t*DLL Name: //g"
else
	if [ -z "$1" ]; then # If no argument is made (e.g. No .exe file specified, display the usage message
		printf "\nFindDLL - Usage:\nfinddll [Windows executable]\n\n"
	else # Otherwise, tell the user that the file specified does not exist
		echo "The file ${FILE} does not exist in the current directory."
	fi
fi

