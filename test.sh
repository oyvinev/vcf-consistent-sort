#!/bin/bash -ue


function vcf_with_random_id() {
    awk -F $'\t' 'BEGIN {OFS=FS} $3=rand()'
}

function vcf_with_unset_id() {
    awk -F $'\t' 'BEGIN {OFS=FS} $3="."'
}

vcf=
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -i|--vcf) vcf="$2"; shift ;;
        -N) N=$2; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

if [[ -z $vcf ]]; then
vcf=$(mktemp)
cat > "$vcf" <<EOL
#CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO
1	123	.	GG	A	.	.	.
1	123	.	G	A	.	.	.
1	123	.	GGT	C	.	.	.
EOL
fi
N=${N:-10}

expected_md5sum=$(cat $vcf | vcf_with_unset_id | vcf-sort -c |  md5sum)

tmp_file=$(mktemp)
for i in $(seq 1 $N); do
    # Shuffle vcf file, and insert random ID fields
    grep "^#" $vcf > $tmp_file
    grep -v "^#" $vcf | vcf_with_random_id - | shuf  >> $tmp_file

    # Run vcf-sort, and vcf-consistent-sort both as pipe and with file input
    md5sum_vcf_sort=$(vcf-sort -c $tmp_file 2>/dev/null | vcf_with_unset_id | md5sum)
    md5sum_pipe=$(cat $tmp_file | ./vcf-consistent-sort | vcf_with_unset_id | md5sum)
    md5sum_file=$(./vcf-consistent-sort $tmp_file | vcf_with_unset_id | md5sum)

    if [[ $md5sum_file != $expected_md5sum ]]; then
        echo "vcf-consistent-sort failed with file input"
        exit 1
    fi

    if [[ $md5sum_pipe != $expected_md5sum ]]; then
        echo "vcf-consistent-sort failed with piped input"
        exit 1
    fi

    if [[ $md5sum_vcf_sort != $expected_md5sum ]]; then
        echo "Inconstent vcf-sort"
    fi
    
    echo "Test $i of $N passed"

done