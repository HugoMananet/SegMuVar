#!/bin/bash
#
fbname=$(basename "$1")
filenoext="${fbname%%.*}"
extension="${fbname##*.}"



if [[ $fbname == *\.vcf ]]
then
	echo -e "\nFile processed is in directory: $(dirname $(readlink -f "$1"))\n"
	echo -e "The file processed is: $fbname\n"
	echo -e "Output files: ${filenoext}_monoallelic_variants_only.vcf & ${filenoext}_multiallelic_variants_only.vcf\n"

	grep -v -e "././" "$1" > "${filenoext}_monoallelic_variants_only.vcf"

	grep -E "././|#" "$1" > "${filenoext}-multiallelic-variants-only.vcf"
	singularity exec \
		-B $PWD,/mnt/isilon_cifs/BIO_INFO/ \
		/mnt/isilon_cifs/BIO_INFO/Hugo/containers_images/singularityfiles/Samtools/1.9/samtools-1.9.simg \
		bcftools norm \
		-O v \
		-m - \
		--threads 2 \
		-o ${filenoext}-multiallelic-variants-only-decomposed-normalized.vcf \
		${filenoext}-multiallelic-variants-only.vcf
		grep -e "^#" ${filenoext}-multiallelic-variants-only-decomposed-normalized.vcf > header
		grep -v -e "^#" ${filenoext}-multiallelic-variants-only-decomposed-normalized.vcf | awk -F"\t" \
			'BEGIN {FS=OFS="\t"; $1=$1}{gsub("0/0/0/0/0/0/0/0/0/0/1","0/10",$10);\
			gsub("0/0/0/0/0/0/0/0/0/1","0/9",$10);\
			gsub("0/0/0/0/0/0/0/0/1/0","0/8",$10);\
			gsub("0/0/0/0/0/0/0/1/0/0","0/8",$10);\
			gsub("0/0/0/0/0/0/1/0/0/0","0/8",$10);\
			gsub("0/0/0/0/0/1/0/0/0/0","0/8",$10);\
			gsub("0/0/0/0/1/0/0/0/0/0","0/8",$10);\
			gsub("0/0/0/1/0/0/0/0/0/0","0/8",$10);\
			gsub("0/0/1/0/0/0/0/0/0/0","0/8",$10);\
			gsub("0/1/0/0/0/0/0/0/0/0","0/8",$10);\
			gsub("0/0/0/0/0/0/0/0/1","0/8",$10);\
			gsub("0/0/0/0/0/0/0/1/0","0/7",$10);\
			gsub("0/0/0/0/0/0/1/0/0","0/6",$10);\
			gsub("0/0/0/0/0/1/0/0/0","0/5",$10);\
			gsub("0/0/0/0/1/0/0/0/0","0/4",$10);\
			gsub("0/0/0/1/0/0/0/0/0","0/3",$10);\
			gsub("0/0/1/0/0/0/0/0/0","0/2",$10);\
			gsub("0/1/0/0/0/0/0/0/0","0/1",$10);\
			gsub("0/0/0/0/0/0/0/1","0/7",$10);\
			gsub("0/0/0/0/0/0/1/0","0/6",$10);\
			gsub("0/0/0/0/0/1/0/0","0/5",$10);\
			gsub("0/0/0/0/1/0/0/0","0/4",$10);\
			gsub("0/0/0/1/0/0/0/0","0/3",$10);\
			gsub("0/0/1/0/0/0/0/0","0/2",$10);\
			gsub("0/1/0/0/0/0/0/0","0/1",$10);\
			gsub("0/0/0/0/0/0/1","0/6",$10);\
			gsub("0/0/0/0/0/1/0","0/5",$10);\
			gsub("0/0/0/0/1/0/0","0/4",$10);\
			gsub("0/0/0/1/0/0/0","0/3",$10);\
			gsub("0/0/1/0/0/0/0","0/2",$10);\
			gsub("0/1/0/0/0/0/0","0/1",$10);\
			gsub("0/0/0/0/0/1","0/5",$10);\
			gsub("0/0/0/0/1/0","0/4",$10);\
			gsub("0/0/0/1/0/0","0/3",$10);\
			gsub("0/0/1/0/0/0","0/2",$10);\
			gsub("0/1/0/0/0/0","0/1",$10);\
			gsub("0/0/0/0/1","0/4",$10);\
			gsub("0/0/0/1/0","0/3",$10);\
			gsub("0/0/1/0/0","0/2",$10);\
			gsub("0/1/0/0/0","0/1",$10);\
			gsub("0/0/0/1","0/3",$10);\
			gsub("0/0/1/0","0/2",$10);\
			gsub("0/1/0/0","0/1",$10);\
			gsub("0/0/1","0/2",$10);\
			gsub("0/1/0","0/1",$10)}\
			{print $0}' | sed 's/ /\t/g' \
			> ${filenoext}-multiallelic-variants-only-decomposed-normalized-rtgready-noheader.vcf
	cat header ${filenoext}-multiallelic-variants-only-decomposed-normalized-rtgready-noheader.vcf \
		> ${filenoext}-multiallelic-variants-only-decomposed-normalized-rtgready.vcf
	rm ${filenoext}-multiallelic-variants-only-decomposed-normalized-rtgready-noheader.vcf
	rm ${filenoext}-multiallelic-variants-only.vcf
	rm ${filenoext}-multiallelic-variants-only-decomposed-normalized.vcf
	rm header
elif [[ $fbname == *\.vcf.gz ]]
then
	echo -e "\nFile processed is in directory: $(dirname $(readlink -f "$1"))\n"
	echo -e "File processed is: $fbname\n"
	echo -e "Output files: ${filenoext}_monoallelic_variants_only.vcf.gz & ${filenoext}_multiallelic_variants_only.vcf.gz\n"

	zgrep -v -E "././" "$1" > "${filenoext}-monoallelic-variants-only.vcf"
	vcf_monoallelic_variants="${filenoext}-monoallelic-variants-only.vcf"
	gzip -k -c ${vcf_monoallelic_variants} > "${filenoext}_monoallelic_variants_only.vcf.gz"
	rm ${vcf_monoallelic_variants}

	zgrep -E "././|#" "$1" > "${filenoext}-multiallelic-variants-only.vcf"
	singularity exec \
		-B $PWD,/mnt/isilon_cifs/BIO_INFO/ \
		/mnt/isilon_cifs/BIO_INFO/Hugo/containers_images/singularityfiles/Samtools/1.9/samtools-1.9.simg \
		bcftools norm \
		-O v \
		-m - \
		--threads 2 \
		-o ${filenoext}-multiallelic-variants-only-decomposed-normalized.vcf \
		${filenoext}-multiallelic-variants-only.vcf
		grep -e "^#" ${filenoext}-multiallelic-variants-only-decomposed-normalized.vcf > header
		grep -v -e "^#" ${filenoext}-multiallelic-variants-only-decomposed-normalized.vcf | awk -F"\t" \
			'BEGIN {FS=OFS="\t"; $1=$1}{gsub("0/0/0/0/0/0/0/0/0/0/1","0/10",$10);\
			gsub("0/0/0/0/0/0/0/0/0/1","0/9",$10);\
			gsub("0/0/0/0/0/0/0/0/1/0","0/8",$10);\
			gsub("0/0/0/0/0/0/0/1/0/0","0/8",$10);\
			gsub("0/0/0/0/0/0/1/0/0/0","0/8",$10);\
			gsub("0/0/0/0/0/1/0/0/0/0","0/8",$10);\
			gsub("0/0/0/0/1/0/0/0/0/0","0/8",$10);\
			gsub("0/0/0/1/0/0/0/0/0/0","0/8",$10);\
			gsub("0/0/1/0/0/0/0/0/0/0","0/8",$10);\
			gsub("0/1/0/0/0/0/0/0/0/0","0/8",$10);\
			gsub("0/0/0/0/0/0/0/0/1","0/8",$10);\
			gsub("0/0/0/0/0/0/0/1/0","0/7",$10);\
			gsub("0/0/0/0/0/0/1/0/0","0/6",$10);\
			gsub("0/0/0/0/0/1/0/0/0","0/5",$10);\
			gsub("0/0/0/0/1/0/0/0/0","0/4",$10);\
			gsub("0/0/0/1/0/0/0/0/0","0/3",$10);\
			gsub("0/0/1/0/0/0/0/0/0","0/2",$10);\
			gsub("0/1/0/0/0/0/0/0/0","0/1",$10);\
			gsub("0/0/0/0/0/0/0/1","0/7",$10);\
			gsub("0/0/0/0/0/0/1/0","0/6",$10);\
			gsub("0/0/0/0/0/1/0/0","0/5",$10);\
			gsub("0/0/0/0/1/0/0/0","0/4",$10);\
			gsub("0/0/0/1/0/0/0/0","0/3",$10);\
			gsub("0/0/1/0/0/0/0/0","0/2",$10);\
			gsub("0/1/0/0/0/0/0/0","0/1",$10);\
			gsub("0/0/0/0/0/0/1","0/6",$10);\
			gsub("0/0/0/0/0/1/0","0/5",$10);\
			gsub("0/0/0/0/1/0/0","0/4",$10);\
			gsub("0/0/0/1/0/0/0","0/3",$10);\
			gsub("0/0/1/0/0/0/0","0/2",$10);\
			gsub("0/1/0/0/0/0/0","0/1",$10);\
			gsub("0/0/0/0/0/1","0/5",$10);\
			gsub("0/0/0/0/1/0","0/4",$10);\
			gsub("0/0/0/1/0/0","0/3",$10);\
			gsub("0/0/1/0/0/0","0/2",$10);\
			gsub("0/1/0/0/0/0","0/1",$10);\
			gsub("0/0/0/0/1","0/4",$10);\
			gsub("0/0/0/1/0","0/3",$10);\
			gsub("0/0/1/0/0","0/2",$10);\
			gsub("0/1/0/0/0","0/1",$10);\
			gsub("0/0/0/1","0/3",$10);\
			gsub("0/0/1/0","0/2",$10);\
			gsub("0/1/0/0","0/1",$10);\
			gsub("0/0/1","0/2",$10);\
			gsub("0/1/0","0/1",$10)}\
			{print $0}' | sed 's/ /\t/g' \
			> ${filenoext}-multiallelic-variants-only-decomposed-normalized-rtgready-noheader.vcf
	cat header ${filenoext}-multiallelic-variants-only-decomposed-normalized-rtgready-noheader.vcf \
		> ${filenoext}_multiallelic-variants-only-decomposed-normalized-rtgready.vcf
	gzip -k -c ${filenoext}_multiallelic-variants-only-decomposed-normalized-rtgready.vcf \
		> ${filenoext}_multiallelic_variants_only_decomposed_normalized_rtgready.vcf.gz
	rm ${filenoext}_multiallelic-variants-only-decomposed-normalized-rtgready.vcf
	rm ${filenoext}-multiallelic-variants-only-decomposed-normalized-rtgready-noheader.vcf
	rm ${filenoext}-multiallelic-variants-only-decomposed-normalized.vcf
	rm ${filenoext}-multiallelic-variants-only.vcf
	rm header
else
	echo -e "\n\n!!!!!!!!!!!!!!!! The file do not have the correct extension, please check file type or extension !!!!!!!!!!!!!!!!\n\n"
fi

# awk -F"\t|:" '{print $21}'
# grep -e "^#" restest_mutect2_tumoronly_multiallelic_variants_only_decomposed_normalized.vcf > header
# grep -v -e "^#" restest_mutect2_tumoronly_multiallelic_variants_only_decomposed_normalized.vcf | awk -F"\t" \
# 	'{gsub("0/0/0/0/0/0/0/0/0/0/1","0/10",$10);\
# 	gsub("0/0/0/0/0/0/0/0/0/1","0/9",$10);\
# 	gsub("0/0/0/0/0/0/0/0/1/0","0/8",$10);\
# 	gsub("0/0/0/0/0/0/0/1/0/0","0/8",$10);\
# 	gsub("0/0/0/0/0/0/1/0/0/0","0/8",$10);\
# 	gsub("0/0/0/0/0/1/0/0/0/0","0/8",$10);\
# 	gsub("0/0/0/0/1/0/0/0/0/0","0/8",$10);\
# 	gsub("0/0/0/1/0/0/0/0/0/0","0/8",$10);\
# 	gsub("0/0/1/0/0/0/0/0/0/0","0/8",$10);\
# 	gsub("0/1/0/0/0/0/0/0/0/0","0/8",$10);\
# 	gsub("0/0/0/0/0/0/0/0/1","0/8",$10);\
# 	gsub("0/0/0/0/0/0/0/1/0","0/7",$10);\
# 	gsub("0/0/0/0/0/0/1/0/0","0/6",$10);\
# 	gsub("0/0/0/0/0/1/0/0/0","0/5",$10);\
# 	gsub("0/0/0/0/1/0/0/0/0","0/4",$10);\
# 	gsub("0/0/0/1/0/0/0/0/0","0/3",$10);\
# 	gsub("0/0/1/0/0/0/0/0/0","0/2",$10);\
# 	gsub("0/1/0/0/0/0/0/0/0","0/1",$10);\
# 	gsub("0/0/0/0/0/0/0/1","0/7",$10);\
# 	gsub("0/0/0/0/0/0/1/0","0/6",$10);\
# 	gsub("0/0/0/0/0/1/0/0","0/5",$10);\
# 	gsub("0/0/0/0/1/0/0/0","0/4",$10);\
# 	gsub("0/0/0/1/0/0/0/0","0/3",$10);\
# 	gsub("0/0/1/0/0/0/0/0","0/2",$10);\
# 	gsub("0/1/0/0/0/0/0/0","0/1",$10);\
# 	gsub("0/0/0/0/0/0/1","0/6",$10);\
# 	gsub("0/0/0/0/0/1/0","0/5",$10);\
# 	gsub("0/0/0/0/1/0/0","0/4",$10);\
# 	gsub("0/0/0/1/0/0/0","0/3",$10);\
# 	gsub("0/0/1/0/0/0/0","0/2",$10);\
# 	gsub("0/1/0/0/0/0/0","0/1",$10);\
# 	gsub("0/0/0/0/0/1","0/5",$10);\
# 	gsub("0/0/0/0/1/0","0/4",$10);\
# 	gsub("0/0/0/1/0/0","0/3",$10);\
# 	gsub("0/0/1/0/0/0","0/2",$10);\
# 	gsub("0/1/0/0/0/0","0/1",$10);\
# 	gsub("0/0/0/0/1","0/4",$10);\
# 	gsub("0/0/0/1/0","0/3",$10);\
# 	gsub("0/0/1/0/0","0/2",$10);\
# 	gsub("0/1/0/0/0","0/1",$10);\
# 	gsub("0/0/0/1","0/3",$10);\
# 	gsub("0/0/1/0","0/2",$10);\
# 	gsub("0/1/0/0","0/1",$10);\
# 	gsub("0/0/1","0/2",$10);\
# 	gsub("0/1/0","0/1",$10)}\
# 	{print $0}' | sed 's/ /\t/g' >
