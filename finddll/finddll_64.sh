#!/bin/bash
# Display a list of required DLLs for a specific exe (x64 Version).

FILE=$1

if [ -f "${FILE}" ]; then # Check if the specified executable exists in the user's current directory before proceeding
	x86_64-w64-mingw32-objdump -p ${FILE} | grep 'DLL Name:' | sed -e "s/\t*DLL Name: //g"
else
	if [ -z "$1" ]; then # If no argument is made (e.g. No .exe file specified, display the usage message
		printf "\nFindDLL (x64) - Usage:\nfinddll_64 [Windows executable]\n\n"
	else # Otherwise, tell the user that the file specified does not exist
		echo "The specified executable ${FILE} does not exist in the current directory."
	fi
fi

