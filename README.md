# SegMuVar

Basic bash script separating multiallelic variants from monoallelic ones and formatiing the multiallelic variants to be decomposed and normalized (via bcftools norm) and reformatted to be RTGeval compatible.

Input available are vcf or vcf.gz

command to launch script : 

```
./segmuvar.sh path/to/your/vcf

```

This script will generate 2 files from your input vcf (staying intact) :

```
name_of_your_file_monoallelic_variants_only.vcf (or vcf.gz)
restest_mutect2_tumoronly-multiallelic-variants-only-decomposed-normalized-rtgready.vcf
```