!/usr/bin/bash
## Program to run sniffles svim and assemblatycs (this last one is optional)
## You need:
#1)  FILE with the names of the bam files
#2)  PATH where to write the results
#3) name of the reference
#4) IF WANT TO RUN ASSEMBLATYCS $4== 1 else $4 == 0
#5) Directory where the assemblies are
##NOTE: the file $1 has to be tab delimited--> example : sample_sorted.bam      sample_assembly_canu.fasta
############################################################################################################################
#USAGE_EXAMPLE:  bash SV_calling.sh file_samples.txt DIR_OUT REF 1 ASSEM_DIR
##########################################################################################################


DIR_OUT=$2
SAMPLES=$1
ref=$3
ASSEM=$4
DIR_ASSEM=$5

##Definition of sniffles_svim_function:
function sniffles_svim {
        samples=($(cut -f 1 "$SAMPLES"))
        for sample in "${samples[@]}"
        do 
                name=($(basename -s ".bam" "$sample"))
                echo "_"
                echo "Calling variants for "${name}" with sniffles............."
                echo "_"
                echo "sniffles --input "${sample}" --vcf "${name}"_sniffles.vcf"
                sniffles --input "${sample}" --vcf "${name}"_sniffles.vcf
                mv "${name}"_sniffles.vcf $DIR_OUT
                echo "Calling variants for "${sample}" with svim................"
                echo "svim reads  "${name}"_SVIM_OUT "${sample}" "${ref}" "
                svim alignment  "${name}"_SVIM_OUT "${sample}" "${ref}"
                cd "${name}"_SVIM_OUT 
                mv variants.vcf "${name}"_svim.vcf
                mv "${name}"_svim.vcf $DIR_OUT
                cd ..
                mv "${name}"_SVIM_OUT $DIR_OUT 
                echo ""
        done
                }

#Running the program:
if (("$ASSEM" == 1)); then
        echo "RUN nucmer for assemblatycs....."
        samples=($(cut -f 2 "$SAMPLES"))
        for assembly in "${samples[@]}"
        do
                name_out=($(basename -s ".fasta" "$assembly"))
                echo "_"
                echo "running nucmer for "${name_out}""
                echo "nucmer -maxmatch -l 100 -c 500 "${ref}" $DIR_ASSEM/"${assembly}" -prefix "${name_out}"_nucmer"
                nucmer -maxmatch -l 100 -c 500 "${ref}" $DIR_ASSEM/"${assembly}" -prefix "${name_out}"_nucmer
                gzip "${name_out}"_nucmer.delta
                mv  "${name_out}"_nucmer.delta.gz "${DIR_OUT}" 
                echo "_"
                echo "now running sniffles and svim"
                sniffles_svim
        done

else
        echo "_"
        echo "Running JUST sniffles and svim"
        sniffles_svim
fi
