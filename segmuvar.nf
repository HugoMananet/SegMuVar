#!/usr/bin/env nextflow

ref = file(params.ref)
resdir = params.resdir
baseline_file = params.baseline
template_dir = params.template+"ucsc.hg19.sdf"
sample_name = params.sample

input = Channel.fromPath(params.vcf)
	.map { file -> filename=file.toString().substring(file.toString().lastIndexOf('/') + 1, file.toString().length());
		tuple(filename.substring(0, filename.indexOf('.')),file)}

process decompress_vcfgz {

	tag "Generate vcf file from vcf.gz"
	label 'samtools'

	input:
		set val(vcf_basename), file(vcf_file) from input

	output:
		set val("${vcf_basename}_decompressed"), file("${vcf_basename}_decompressed.vcf") into (vcf_channel1, vcf_channel2)

		"""
			bcftools view \
			--threads 2 \
			--no-update \
			-o ${vcf_basename}_decompressed.vcf \
			${vcf_file}
		"""
}

process generateMono {

	// publishDir ".", mode: 'copy', overwrite: true

	tag "Generate monoallelic variant for ${vcf_mono_basename}"

	input:
		set val(vcf_mono_basename),file(vcf_mono_file) from vcf_channel1

	output:
		set val("${vcf_mono_basename}_monoallelic_variants_only"), file("${vcf_mono_basename}_monoallelic_variants_only.vcf") into (mono_vcf_channel)

	"""
		grep -v -e "././" ${vcf_mono_file} > ${vcf_mono_basename}_monoallelic_variants_only.vcf
	"""
}

process compress_vcf_mono{

	publishDir "${resdir}", mode: 'copy', overwrite: true

	label 'bcftools'

	tag "Compression monoallelic vcf file ${vcf_mono_basename}.vcf"

	input:
		set val(vcf_mono_basename), file(vcf_mono_file) from mono_vcf_channel

	output:
		file("${vcf_mono_basename}.vcf.gz") into (blabla2_channel, rtg_monochannel)

	"""
		bcftools view \
		-O z \
		-o ${vcf_mono_basename}.vcf.gz \
		--threads 2 \
		${vcf_mono_file}
	"""
}


process generateMulti {

	tag "Generate multiallelic variant for ${vcf_multi_basename}.vcf"

	input:
		set val(vcf_multi_basename),file(vcf_multi_file) from vcf_channel2

	output:
		set val("${vcf_multi_basename}_multiallelic_variants_only"), file("${vcf_multi_basename}_multiallelic_variants_only.vcf") into (multi_vcf_channel)

	"""
		grep -E "././|#" ${vcf_multi_basename}.vcf > ${vcf_multi_basename}_multiallelic_variants_only.vcf
	"""
}

process bcftools_deco_norm{

	label 'bcftools'

	tag "Normalize & decompose file ${vcf_multi_basename}"

	input:
		set val(vcf_multi_basename), file(vcf_multi_file) from multi_vcf_channel

	output:
		set val("${vcf_multi_basename}_decomposed_normalized"), file("${vcf_multi_basename}_decomposed_normalized.vcf") into (deco_norm_channel1, deco_norm_channel2)

	"""
		bcftools norm \
		-O v \
		-m - \
		-f ${ref} \
		--threads 2 \
		-o ${vcf_multi_basename}_decomposed_normalized.vcf \
		${vcf_multi_file}
	"""
}

process extract_header{

	tag "Extracting header from ${vcf_deco_norm_basename}"

	input:
		set val(vcf_deco_norm_basename), file(vcf_deco_norm_file) from deco_norm_channel1

	output:
		file("header") into (header_channel)

	"""
		grep -e "^#" ${vcf_deco_norm_file} > header
	"""
}

process prepare_4_rtg{

	tag "Prepare for RTG file ${vcf_deco_norm_basename}"

	input:
		set val(vcf_deco_norm_basename), file(vcf_deco_norm_file) from deco_norm_channel2

	output:
		set val("${vcf_deco_norm_basename}_rtgready"), file("${vcf_deco_norm_basename}_rtgready.vcf") into (rtgready_channel)

	"""
		grep -v -e "^#" ${vcf_deco_norm_file} | \
		prepare4rtg.awk | \
		sed 's/ /\t/g' \
		> ${vcf_deco_norm_basename}_rtgready.vcf
	"""
}

process add_header{

	tag "Adding header to file ${vcf_rtgready_basename}"

	input:
		set val(vcf_rtgready_basename), file(vcf_rtg_ready_file) from rtgready_channel
		file(header) from header_channel

	output:
		set val("${vcf_rtgready_basename}_final"), file("${vcf_rtgready_basename}_final.vcf") into (final_vcf_channel)

	"""
		cat ${header} ${vcf_rtg_ready_file} > ${vcf_rtgready_basename}_final.vcf
	"""
}

process compress_vcf_multi{

	publishDir "${resdir}", mode: 'copy', overwrite: true

	label 'bcftools'

	tag "Compression multiallelic vcf file ${vcf_final_basename}"

	input:
		set val(vcf_final_basename), file(vcf_final_file) from final_vcf_channel

	output:
		file("${vcf_final_basename}.vcf.gz") into (blabla_channel, rtg_multichannel)

	"""
		bcftools view \
		-O z \
		-o ${vcf_final_basename}.vcf.gz \
		--threads 2 \
		${vcf_final_file}
	"""
}

process index_vcf_multi{

	publishDir "${resdir}", mode: 'copy', overwrite: true

	label 'bcftools'

	tag "Index creation for multiallelic vcf file ${vcf_final_file}"

	input:
		file(vcf_final_file) from blabla_channel

	output:
		file("${vcf_final_file}.tbi") into (index_vcf_multi_channel)

	"""
		bcftools index \
		-t \
		-o ${vcf_final_file}.tbi \
		${vcf_final_file}
	"""
}

process index_vcf_mono{

	publishDir "${resdir}", mode: 'copy', overwrite: true

	label 'bcftools'

	tag "Index creation for monoallelic vcf file ${vcf_final_file}"

	input:
		file(vcf_final_file) from blabla2_channel

	output:
		file("${vcf_final_file}.tbi") into (index_vcf_mono_channel)

	"""
		bcftools index \
		-t \
		-o ${vcf_final_file}.tbi \
		${vcf_final_file}
	"""
}


// Non focntionnal part of the script
process rtg_tools_monoallelic{

	publishDir "${resdir}", mode: 'copy'

	tag "rtg vcfeval for monoallelic variants "

	label 'samtools'

	input:
		file(called_file) from rtg_monochannel
		file(index) from index_vcf_mono_channel

	output:
	file("${resdir}") into (rtg_monoallelic_output)


	"""
		java -jar /opt/rtg-tools-3.9.1/RTG.jar vcfeval \
		--output-mode=split \
		--sample ${sample_name} \
		-T 2 \
		-b ${baseline_file} \
		-c ${called_file} \
		-o ${resdir} \
		-t ${template_dir}
	"""

}

process rtg_tools_multiallelic{

	publishDir "${resdir}", mode: 'copy'

	tag "rtg vcfeval for monoallelic variants "

	label 'rtg_tools'

	input:
		file(called_file) from rtg_multichannel
		file(index) from index_vcf_multi_channel

	output:
	file("${resdir}") into (rtg_multiallelic_output)

	"""
		java -jar /opt/rtg-tools-3.9.1/RTG.jar vcfeval \
		--output-mode=split \
		--sample ${sample_name} \
		-T 2 \
		--squash-ploidy \
		-b ${baseline_file} \
		-c ${called_file} \
		-o ${resdir} \
		-t ${template_dir}
	"""
}
