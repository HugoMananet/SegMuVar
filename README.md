# SegMuVar -- Segragate Mutect2 Multiallelic Variants

Nextflow script separating multiallelic variants from monoallelic ones, to allow RTGeval to run on the vcfs

Needed to run the script :
- singularity image of Samtools/bcftools (tested with v1.9)
- vcf file generated with Mutect2 (GATK 4)
- Fasta file (with index and dict) to be used with bcftools norm

Input available are vcf

command to launch script : 

```
nextflow run segmuvar.nf --ref path/to/ref/fasta --vcf path/to/vcf
```

This script will generate 2 files from your input vcf (staying intact) :

```
name_of_your_file_monoallelic_variants_only.vcf (& vcf.gz)
restest_mutect2_tumoronly-multiallelic-variants-only-decomposed-normalized-rtgready.vcf (& vcf.gz)
```