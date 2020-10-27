#!/bin/bash

#set -e # exit if pipeline returns non-zero status
#set -o pipefail # return value of last command to exit with non-zero status

database_dir=0
name="signal-results"

HELP="""
Generate directory (in the current working directory) with symbolic links to SIGNAL output. 
Flags:
    -d  :  Absolute path to directory containing output from SIGNAL pipeline.
    -n  :  Name of output directory (default: 'signal-results') - directory must not already exist - should match in config.yaml for ncov-tools.
"""

while getopts ":d:n:" option; do
    case "${option}" in
        d) database_dir=$OPTARG;;
        n) name=$OPTARG;;
    esac
done

if [ $database_dir = 0 ] ; then
	echo "You must specify a data directory containing SIGNAL output."
	echo "$HELP"
	exit 1
fi

if [ -d $(pwd)/${name} ]; then
	echo "Output directory already exists."
	echo "$HELP"
	exit 1
else
	mkdir $name
fi

for dir in ${database_dir}/*; do
	if [ "${dir}" == "${database_dir}/.snakemake" ] ; then
		continue
	fi
	# if [ "${dir}" == "summary" ] ; then
		# continue
	# fi 
	sample=$(basename ${dir})
	echo "${dir}/core/${sample}.consensus.fa"
	ln -s ${dir}/core/${sample}.consensus.fa ${name}/${sample}.consensus.fa
	echo "${dir}/core/${sample}_viral_reference.mapping.primertrimmed.sorted.bam"
	ln -s ${dir}/core/${sample}_viral_reference.mapping.primertrimmed.sorted.bam ${name}/${sample}.sorted.bam
	echo "${dir}/core/${sample}_ivar_variants.tsv"
	ln -s ${dir}/core/${sample}_ivar_variants.tsv ${name}/${sample}.variants.tsv
done

echo -e "\nIgnore any errors from cleanup.\n"

rm ${name}/summary*
rm ${name}/config.yaml*
rm ${name}/*.csv{.consensus.fa,.sorted.bam,.variants.tsv}
rm ${name}/*.tsv{.consensus.fa,.sorted.bam,.variants.tsv}
rm ${name}/bioproject*
rm ${name}/results*
rm ${name}/ncov-tools-results.{consensus.fa,sorted.bam,variants.tsv}

echo -e "\nDon't forget to update the config.yaml file prior to running ncov-tools."
