#!/bin/bash

# 20260216 gjw Pairwise compare files and run meld to update.

# set -x

SCRIPTS=${HOME}/projects/scripts/flutter
FILES=(
    ".gitignore" "${SCRIPTS}/gitignore"
    "support/update.sh"  "${SCRIPTS}/../support/update.sh"
    "support/flutter.mk"  "${SCRIPTS}/../support/flutter.mk"
)

length=${#FILES[@]}

for ((i=0; i < length; i+=2)); do
    f1=${FILES[i]}
    f2=${FILES[i+1]}

    if [ -f "$f1" ] && [ -f "$f2" ]; then
	if ! cmp -s "$f1" "$f2"; then
	    echo "MELD      $f1 $f2"
	    meld "$f1" "$f2" 2> /dev/null
	else
	    echo "IDENTICAL $f1 $f2"
	fi
    else
	echo "MISSING   $f1 $f2"
    fi
done

#         file1=${FILES[i]}
#         file2=${FILES[i+1]}

#         # Check if file1 exists
#         if [ -f "$file1" ] && [ -f "${SCRIPTS}/$file1" ]; then
#             # Check if file2 exists
#             if [ -n "$file2" ] && [ -f "$file2" ] && [ -f "${SCRIPTS}/$file2" ]; then
#                 # Compare files
#                 if ! cmp -s "$file1" "${SCRIPTS}/$file1" || ! cmp -s "$file2" "${SCRIPTS}/$file2"; then
#                     echo "Files $file1 and ${SCRIPTS}/$file1 are different. Opening meld..."
#                     meld "$file1" "${SCRIPTS}/$file1" &
#                     echo "Files $file2 and ${SCRIPTS}/$file2 are different. Opening meld..."
#                     meld "$file2" "${SCRIPTS}/$file2" &
#                 else
#                     echo "Files $file1 and ${SCRIPTS}/$file1, and $file2 and ${SCRIPTS}/$file2 are identical."
#                 fi
#             elif [ -n "$file2" ]; then
#                 echo "File $file2 or ${SCRIPTS}/$file2 does not exist."
#             fi
#         else
#             echo "File $file1 or ${SCRIPTS}/$file1 does not exist."
#         fi
#     done
