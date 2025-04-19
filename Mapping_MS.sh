!/usr/bin/bash
## Program to map reads vs. a reference with minimap:
## You need:
#1)  FILE with the names of the assemblies or reads  are
#2)  PATH where  to run  
#3) name of the reference
#####

#DIR=$2
#cd $DIR
SAMPLES=$1
ref=$2
DIR_FASTQ=$3
samples=($(cut -f 1 "$SAMPLES"))

for sample in "${samples[@]}"
do 
        name=($(basename -s ".fastq" "$sample"))
        echo "Mapping sample: "${name}" with minimap............."
        echo "minimap2 -ax map-ont "${ref}" "$sample" >  "${name}"_minimap.sam"
        #echo "minimap2 -t 12 -ax asm5 --eqx "${ref}" "${sample}" >  "${name}"_minimap.sam"
        #minimap2 -t 12 -ax asm5 --eqx "${ref}" "${sample}" >  "${name}"_minimap.sam
        echo "minimap2 -ax map-ont "${ref}" $DIR_FASTQ/"${name}".fastq >  "${name}"_minimap.sam"
        minimap2 -ax map-ont "${ref}" $DIR_FASTQ/"${name}".fastq >  "${name}"_minimap.sam
        echo "samtools...."
        samtools view -S -b "${name}"_minimap.sam > "${name}"_minimap.bam
        samtools sort "${name}"_minimap.bam -o "${name}"_minimap_sorted.bam
        samtools index "${name}"_minimap_sorted.bam
        samtools depth -a "${name}"_minimap_sorted.bam > "${name}"_minimap_sorted.coverage
        samtools stats "${name}"_minimap_sorted.bam | grep '^SN' | cut -f 2- > "${name}"_map_stats.txt
        samtools idxstats "${name}"_minimap_sorted.bam > "${name}"-reads-chr.txt
        rm "${name}"_minimap.sam 

done
