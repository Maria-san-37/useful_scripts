#!/usr/bin/bash
set -e 
set -u
set -o pipefail

query_len=$3
REF=$2samples=($(cut -f 1 $1))
for sample in "${samples[@]}"
 do
        name=($(basename -s ".fa" "$sample"))
        mummer -mumreference -c -b $REF "${name}" > "${name}".mums
        mummerplot -x "[0,275287]" -y "[0,"${query_len}"]" -postscript -p mummer "${name}".mums --color 
        mv mummer.ps "${name}".ps
 done
