# vcf-consistent-sort
Sort VCFs based on chromosome, position, ref and alt

The commonly used vcf-sort (https://github.com/vcftools/vcftools/blob/master/src/perl/vcf-sort) resorts to sorting on chromosome and position only (`sort -k1,1V -k2,2n`), and on matches, will sort on full line (GNU sort last resort). This will in practice mean that a consistent sort on _variants_ (chrom, pos, ref, alt) is not possible, as this is only true if the ID column is matching.

Take the following examples:

```
#CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO
1	123	.	GG	A	.	.	.
1	123	.	G	A	.	.	.
```

```
#CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO
1	123	some_id	GG	A	.	.	.
1	123	another_id	G	A	.	.	.
```

These files have the same variants, but will be sorted different by `vcf-sort` due to the differing ID field.

This package re-implements `vcf-sort -c` with the addition of `-k4,5` to sort consistently on full variants.

## Requirements

- bash
- GNU coreutils

*NOT* Perl
