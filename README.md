# vcfsplitter

This is a bash script to convert a combined vcf file into separate sample-specific vcf files, while preserving the header and common fields of the combined vcf. Script will name each sample-specific vcf file with the sample name it reads from the combined vcf.

```sh
#!/bin/bash

#separate header into header.txt
awk '/##/ { print }' $1 > header.txt

#separate rest of the file to body.txt
awk '!/##/ { print }' $1 > body.txt

#tab separate body
wget https://raw.githubusercontent.com/milospjanic/tabsep/master/tabsep.sh
chmod 755 tabsep.sh
./tabsep.sh body.txt

#separate common columns and sample columns into common.txt and columns.txt
cut -f 1-9 body.txt > common.txt

cut -f 10- body.txt > columns.txt

#use awk to get number of columns i.e. number of samples
NCOLUMNS=$(awk 'NR==1{print NF}' columns.txt) 

#cut each column and save as separate file, numbered from 1 to $NCOLUMNS
for i in `seq 1 $NCOLUMNS`;
        do
                cut -f $i columns.txt > $i.txt
        done    

#paste common columns to each file
for i in `seq 1 $NCOLUMNS`;
        do
                 paste -d' '  common.txt $i.txt > $i.paste.txt
		 ./tabsep.sh $i.paste.txt
        done    

#concatenate header to each file
for i in `seq 1 $NCOLUMNS`;
        do
                 cat header.txt $i.paste.txt >$i.vcf
                 ./tabsep.sh $i.vcf
        done

#remove intermediary files
for i in `seq 1 $NCOLUMNS`;
        do
                 rm $i.txt
                 rm $i.paste.txt
        done

#use awk to get sample name, place it in variable $SAMPLE and change each file's name accordingly
for i in `seq 1 $NCOLUMNS`;
        do
                 SAMPLE=$(awk '/#(CHROM|CHR|chrom|chr)/ {printf $10}' $i.vcf);
                 mv $i.vcf $SAMPLE.vcf
        done

#remove files
rm columns.txt
rm common.txt
rm header.txt
rm body.txt
```

##Usage

Example vcf:

```
##fileformat=VCFv4.2
##FILTER=<ID=PASS,Description="All filters passed">
##filedate=20160515
##source="beagle.03May16.862.jar (version 4.1)"
##INFO=<ID=AF,Number=A,Type=Float,Description="Estimated ALT Allele Frequencies">
##INFO=<ID=AR2,Number=1,Type=Float,Description="Allelic R-Squared: estimated squared correlation between most probable REF dose and true REF dose">
##INFO=<ID=DR2,Number=1,Type=Float,Description="Dosage R-Squared: estimated squared correlation between estimated REF dose [P(RA) + 2*P(RR)] and true REF dose">
##INFO=<ID=IMP,Number=1,Type=Flag,Description="Imputed marker">
##FORMAT=<ID=GT,Number=1,Type=String,Description="Genotype">
##FORMAT=<ID=DS,Number=1,Type=Float,Description="estimated ALT dose [P(RA) + P(AA)]">
##FORMAT=<ID=GP,Number=G,Type=Float,Description="Estimated Genotype Probability">
##contig=<ID=chr1>
##contig=<ID=chr2>
##contig=<ID=chr3>
##contig=<ID=chr4>
##contig=<ID=chr5>
##contig=<ID=chr6>
##contig=<ID=chr7>
##contig=<ID=chr8>
##contig=<ID=chr9>
##contig=<ID=chr10>
##contig=<ID=chr11>
##contig=<ID=chr12>
##contig=<ID=chr13>
##contig=<ID=chr14>
##contig=<ID=chr15>
##contig=<ID=chr16>
##contig=<ID=chr17>
##contig=<ID=chr18>
##contig=<ID=chr19>
##contig=<ID=chr20>
##contig=<ID=chr21>
##contig=<ID=chr22>
##bcftools_concatVersion=1.3+htslib-1.3
##bcftools_concatCommand=concat -Ov -o recalibrated_biallelic_SNP.beagle.vcf recalibrated_biallelic_SNP.beagle.chr1.vcf.gz recalibrated_biallelic_SNP.beagle.chr2.vcf.gz recalibrated_biallelic_SNP.beagle.chr3.vcf.gz recalibrated_biallelic_SNP.beagle.chr4.vcf.gz recalibrated_biallelic_SNP.beagle.chr5.vcf.gz recalibrated_biallelic_SNP.beagle.chr6.vcf.gz recalibrated_biallelic_SNP.beagle.chr7.vcf.gz recalibrated_biallelic_SNP.beagle.chr8.vcf.gz recalibrated_biallelic_SNP.beagle.chr9.vcf.gz recalibrated_biallelic_SNP.beagle.chr10.vcf.gz recalibrated_biallelic_SNP.beagle.chr11.vcf.gz recalibrated_biallelic_SNP.beagle.chr12.vcf.gz recalibrated_biallelic_SNP.beagle.chr13.vcf.gz recalibrated_biallelic_SNP.beagle.chr14.vcf.gz recalibrated_biallelic_SNP.beagle.chr15.vcf.gz recalibrated_biallelic_SNP.beagle.chr16.vcf.gz recalibrated_biallelic_SNP.beagle.chr17.vcf.gz recalibrated_biallelic_SNP.beagle.chr18.vcf.gz recalibrated_biallelic_SNP.beagle.chr19.vcf.gz recalibrated_biallelic_SNP.beagle.chr20.vcf.gz recalibrated_biallelic_SNP.beagle.chr21.vcf.gz recalibrated_biallelic_SNP.beagle.chr22.vcf.gz
##bcftools_viewVersion=1.3+htslib-1.3
##bcftools_viewCommand=view -e INFO/DR2<0.8 -o recalibrated_biallelic_SNP.beagle.rename.dr2.vcf recalibrated_biallelic_SNP.beagle.rename.vcf
##bcftools_viewCommand=view -T pass_hwe.txt -Ov -o recalibrated_biallelic_SNP.beagle.rename.dr2.hwe.vcf recalibrated_biallelic_SNP.beagle.rename.dr2.vcf
#CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO	FORMAT	1020301	102901	1042702	1051601	1060602	10705	112201	1278	1346	1347	1369	1386	1448	1483	1497	1522	1559	1576	1587	1596	177089	1795	1923	200212	2030801	2040401	20805	2105	1508	2115	2135	2139	2161	2228	2282	2305	2356	24156	2435	2463	2477	2510	2999	2989	3003	3100203	3101801	317155	59386145	59885590	7103002	8072501	8100901	9052004	9070202	9071501	9090701	1401
chr1	746189	rs139221807	A	G	.	PASS	AR2=1;DR2=1;AF=0.034	GT:DS:GP	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/1:1:0,1,0	0/0:0:1,0,0	0/0:0:1,0,0	0/1:1:0,1,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/1:1:0,1,0	0/0:0:1,0,0	0/1:1:0,1,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0
chr1	752270	rs181450891	T	A	.	PASS	AR2=1;DR2=1;AF=0.0086	GT:DS:GP	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/1:1:0,1,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0
chr1	752478	rs146277091	G	A	.	PASS	AR2=1;DR2=1;AF=0.034	GT:DS:GP	0/0:0:1,0,0	0/0:0:1,0,0	0/1:1:0,1,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0/1:1:0,1,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/1:1:0,1,0	0/0:0:1,0,0	0/1:1:0,1,0	0/0:0:1,0,0	0/0:0:1,0,0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0
chr1	752566	rs3094315	G	A	.	PASS	AR2=1;DR2=1;AF=0.74	GT:DS:GP	1/1:2:0,0,1	1/1:2:0,0,1	0/1:1:0,1,0	0/1:1:0,1,0	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	0/0:0:1,0,0	0/1:1:0,1,0	1/1:2:0,0,1	1/1:2:0,0,1	0/1:1:0,1,0	0/0:0:1,0,0	0/0:0:1,0,0/1:1:0,1,0	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	0/1:1:0,1,0	1/1:2:0,0,1	0/1:1:0,1,0	0/1:1:0,1,0	0/0:0:1,0,0	1/1:2:0,0,1	1/1:2:0,0,1	0/1:1:0,1,1/1:2:0,0,1	0/1:1:0,1,0	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	0/0:0:1,0,0	1/1:2:0,0,1	0/0:0:1,0,0	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,0/1:1:0,1,0	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	0/1:1:0,1,0	0/1:1:0,1,0	0/1:1:0,1,0	1/1:2:0,0,1	0/1:1:0,1,1/1:2:0,0,1	0/0:0:1,0,0	1/1:2:0,0,1	1/1:2:0,0,1	0/1:1:0,1,0
chr1	752593	rs372531941	T	G	.	PASS	AR2=1;DR2=1;AF=0.034	GT:DS:GP	0/0:0:1,0,0	0/0:0:1,0,0	0/1:1:0,1,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0/1:1:0,1,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/1:1:0,1,0	0/0:0:1,0,0	0/1:1:0,1,0	0/0:0:1,0,0	0/0:0:1,0,0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0
chr1	752617	rs149886465	C	A	.	PASS	AR2=1;DR2=1;AF=0.034	GT:DS:GP	0/0:0:1,0,0	0/0:0:1,0,0	0/1:1:0,1,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0/1:1:0,1,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/1:1:0,1,0	0/0:0:1,0,0	0/1:1:0,1,0	0/0:0:1,0,0	0/0:0:1,0,0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0
chr1	752721	rs3131972	A	G	.	PASS	AR2=1;DR2=1;AF=0.72	GT:DS:GP	1/1:2:0,0,1	1/1:2:0,0,1	0/1:1:0,1,0	0/1:1:0,1,0	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	0/0:0:1,0,0	0/1:1:0,1,0	1/1:2:0,0,1	1/1:2:0,0,1	0/1:1:0,1,0	0/0:0:1,0,0	0/0:0:1,0,0/1:1:0,1,0	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	0/1:1:0,1,0	1/1:2:0,0,1	0/1:1:0,1,0	0/1:1:0,1,0	0/0:0:1,0,0	1/1:2:0,0,1	1/1:2:0,0,1	0/1:1:0,1,1/1:2:0,0,1	0/1:1:0,1,0	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	0/0:0:1,0,0	0/1:1:0,1,0	0/0:0:1,0,0	1/1:2:0,0,1	1/1:2:0,0,1	0/1:1:0,1,0/1:1:0,1,0	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	0/1:1:0,1,0	0/1:1:0,1,0	0/1:1:0,1,0	1/1:2:0,0,1	0/1:1:0,1,1/1:2:0,0,1	0/0:0:1,0,0	1/1:2:0,0,1	1/1:2:0,0,1	0/1:1:0,1,0
chr1	753541	rs2073813	G	A	.	PASS	AR2=1;DR2=1;AF=0.22	GT:DS:GP	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/1:1:0,1,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	1/1:2:0,0,1	0/1:1:0,1,0	0/0:0:1,0,0	0/0:0:1,0,0	0/1:1:0,1,0	1/1:2:0,0,1	1/1:2:0,0,0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/1:1:0,1,0	0/0:0:1,0,0	0/1:1:0,1,0	0/1:1:0,1,0	1/1:2:0,0,1	0/0:0:1,0,0	0/0:0:1,0,0	0/1:1:0,1,0/0:0:1,0,0	0/1:1:0,1,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/1:1:0,1,0	0/1:1:0,1,0	0/1:1:0,1,0	0/0:0:1,0,0	0/0:0:1,0,0	0/1:1:0,1,0/1:1:0,1,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/1:1:0,1,0	0/0:0:1,0,0	0/0:0:1,0,0	0/1:1:0,1,0/0:0:1,0,0	1/1:2:0,0,1	0/0:0:1,0,0	0/0:0:1,0,0	0/1:1:0,1,0
chr1	754182	rs3131969	A	G	.	PASS	AR2=1;DR2=1;AF=0.77	GT:DS:GP	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	0/1:1:0,1,0	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	0/0:0:1,0,0	0/1:1:0,1,0	1/1:2:0,0,1	1/1:2:0,0,1	0/1:1:0,1,0	0/0:0:1,0,0	0/0:0:1,0,1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	0/1:1:0,1,0	1/1:2:0,0,1	0/1:1:0,1,0	0/1:1:0,1,0	0/0:0:1,0,0	1/1:2:0,0,1	1/1:2:0,0,1	0/1:1:0,1,1/1:2:0,0,1	0/1:1:0,1,0	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	0/1:1:0,1,0	0/1:1:0,1,0	0/0:0:1,0,0	1/1:2:0,0,1	1/1:2:0,0,1	0/1:1:0,1,0/1:1:0,1,0	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	0/1:1:0,1,0	1/1:2:0,0,1	1/1:2:0,0,1	0/1:1:0,1,1/1:2:0,0,1	0/0:0:1,0,0	1/1:2:0,0,1	1/1:2:0,0,1	0/1:1:0,1,0
chr1	754192	rs3131968	A	G	.	PASS	AR2=1;DR2=1;AF=0.77	GT:DS:GP	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	0/1:1:0,1,0	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	0/0:0:1,0,0	0/1:1:0,1,0	1/1:2:0,0,1	1/1:2:0,0,1	0/1:1:0,1,0	0/0:0:1,0,0	0/0:0:1,0,1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	0/1:1:0,1,0	1/1:2:0,0,1	0/1:1:0,1,0	0/1:1:0,1,0	0/0:0:1,0,0	1/1:2:0,0,1	1/1:2:0,0,1	0/1:1:0,1,1/1:2:0,0,1	0/1:1:0,1,0	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	0/1:1:0,1,0	0/1:1:0,1,0	0/0:0:1,0,0	1/1:2:0,0,1	1/1:2:0,0,1	0/1:1:0,1,0/1:1:0,1,0	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	0/1:1:0,1,0	1/1:2:0,0,1	1/1:2:0,0,1	0/1:1:0,1,1/1:2:0,0,1	0/0:0:1,0,0	1/1:2:0,0,1	1/1:2:0,0,1	0/1:1:0,1,0
chr1	754334	rs3131967	T	C	.	PASS	AR2=1;DR2=1;AF=0.77	GT:DS:GP	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	0/1:1:0,1,0	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	0/0:0:1,0,0	0/1:1:0,1,0	1/1:2:0,0,1	1/1:2:0,0,1	0/1:1:0,1,0	0/0:0:1,0,0	0/0:0:1,0,1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	0/1:1:0,1,0	1/1:2:0,0,1	0/1:1:0,1,0	0/1:1:0,1,0	0/0:0:1,0,0	1/1:2:0,0,1	1/1:2:0,0,1	0/1:1:0,1,1/1:2:0,0,1	0/1:1:0,1,0	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	0/1:1:0,1,0	0/1:1:0,1,0	0/0:0:1,0,0	1/1:2:0,0,1	1/1:2:0,0,1	0/1:1:0,1,0/1:1:0,1,0	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	1/1:2:0,0,1	0/1:1:0,1,0	1/1:2:0,0,1	1/1:2:0,0,1	0/1:1:0,1,1/1:2:0,0,1	0/0:0:1,0,0	1/1:2:0,0,1	1/1:2:0,0,1	0/1:1:0,1,0
chr1	754429	rs114339855	T	G	.	PASS	AR2=1;DR2=1;AF=0.0086	GT:DS:GP	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/1:1:0,1,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0
chr1	754433	rs150578204	G	A	.	PASS	AR2=1;DR2=1;AF=0.0086	GT:DS:GP	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/1:1:0,1,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0
chr1	754458	rs142682604	G	T	.	PASS	AR2=0.99;DR2=0.99;AF=0.0087	GT:DS:GP	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/1:1:0,1,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0.01:0.99,0.01,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0	0/0:0:1,0,0

```

Run the script providing the vcf file name as argument:

```
chmod 755 vcfsplitter.sh
./vcfsplitter.sh test.vcf
```

The output is initial vcf file separated into sample specific vcf file adequately named:

```
mpjanic@valkyr:~/vcfspliter$ ls -ltrh
total 256K
-rwxrwxr-x 1 mpjanic mpjanic  706 Feb  5 19:19 vcfspl.sh
-rw-rw-r-- 1 mpjanic mpjanic  14K Feb  5 19:55 test.vcf
-rw-rw-r-- 1 mpjanic mpjanic 3.8K Feb  5 21:54 1020301.vcf
-rw-rw-r-- 1 mpjanic mpjanic 3.8K Feb  5 21:54 102901.vcf
-rw-rw-r-- 1 mpjanic mpjanic 3.8K Feb  5 21:54 1042702.vcf
-rw-rw-r-- 1 mpjanic mpjanic 3.8K Feb  5 21:54 1051601.vcf
-rw-rw-r-- 1 mpjanic mpjanic 3.8K Feb  5 21:54 1060602.vcf
-rw-rw-r-- 1 mpjanic mpjanic 3.8K Feb  5 21:54 10705.vcf
-rw-rw-r-- 1 mpjanic mpjanic 3.8K Feb  5 21:54 112201.vcf
-rw-rw-r-- 1 mpjanic mpjanic 3.8K Feb  5 21:54 1278.vcf
-rw-rw-r-- 1 mpjanic mpjanic 3.8K Feb  5 21:54 1346.vcf
-rw-rw-r-- 1 mpjanic mpjanic 3.8K Feb  5 21:54 1347.vcf
-rw-rw-r-- 1 mpjanic mpjanic 3.8K Feb  5 21:54 1369.vcf
-rw-rw-r-- 1 mpjanic mpjanic 3.8K Feb  5 21:54 1386.vcf
-rw-rw-r-- 1 mpjanic mpjanic 3.8K Feb  5 21:54 1448.vcf
-rw-rw-r-- 1 mpjanic mpjanic 3.8K Feb  5 21:54 1483.vcf
-rw-rw-r-- 1 mpjanic mpjanic 3.8K Feb  5 21:54 1497.vcf
-rw-rw-r-- 1 mpjanic mpjanic 3.8K Feb  5 21:54 1522.vcf
-rw-rw-r-- 1 mpjanic mpjanic 3.9K Feb  5 21:54 1559.vcf
-rw-rw-r-- 1 mpjanic mpjanic 3.8K Feb  5 21:54 1576.vcf
-rw-rw-r-- 1 mpjanic mpjanic 3.8K Feb  5 21:54 1587.vcf
-rw-rw-r-- 1 mpjanic mpjanic 3.8K Feb  5 21:54 1596.vcf
-rw-rw-r-- 1 mpjanic mpjanic 3.8K Feb  5 21:54 177089.vcf
-rw-rw-r-- 1 mpjanic mpjanic 3.8K Feb  5 21:54 1795.vcf
-rw-rw-r-- 1 mpjanic mpjanic 3.8K Feb  5 21:54 1923.vcf
-rw-rw-r-- 1 mpjanic mpjanic 3.8K Feb  5 21:54 200212.vcf
-rw-rw-r-- 1 mpjanic mpjanic 3.8K Feb  5 21:54 2030801.vcf
-rw-rw-r-- 1 mpjanic mpjanic 3.8K Feb  5 21:54 2040401.vcf
-rw-rw-r-- 1 mpjanic mpjanic 3.8K Feb  5 21:54 20805.vcf
-rw-rw-r-- 1 mpjanic mpjanic 3.9K Feb  5 21:54 2105.vcf
-rw-rw-r-- 1 mpjanic mpjanic 3.8K Feb  5 21:54 1508.vcf
-rw-rw-r-- 1 mpjanic mpjanic 3.8K Feb  5 21:54 2115.vcf
-rw-rw-r-- 1 mpjanic mpjanic 3.8K Feb  5 21:54 2135.vcf
-rw-rw-r-- 1 mpjanic mpjanic 3.8K Feb  5 21:54 2139.vcf
-rw-rw-r-- 1 mpjanic mpjanic 3.8K Feb  5 21:54 2161.vcf
-rw-rw-r-- 1 mpjanic mpjanic 3.8K Feb  5 21:54 2228.vcf
-rw-rw-r-- 1 mpjanic mpjanic 3.8K Feb  5 21:54 2282.vcf
-rw-rw-r-- 1 mpjanic mpjanic 3.8K Feb  5 21:54 2305.vcf
-rw-rw-r-- 1 mpjanic mpjanic 3.8K Feb  5 21:54 2356.vcf
-rw-rw-r-- 1 mpjanic mpjanic 3.8K Feb  5 21:54 24156.vcf
-rw-rw-r-- 1 mpjanic mpjanic 3.9K Feb  5 21:54 2435.vcf
-rw-rw-r-- 1 mpjanic mpjanic 3.8K Feb  5 21:54 2463.vcf
-rw-rw-r-- 1 mpjanic mpjanic 3.8K Feb  5 21:54 2477.vcf
-rw-rw-r-- 1 mpjanic mpjanic 3.8K Feb  5 21:54 2510.vcf
-rw-rw-r-- 1 mpjanic mpjanic 3.8K Feb  5 21:54 2999.vcf
-rw-rw-r-- 1 mpjanic mpjanic 3.8K Feb  5 21:54 2989.vcf
-rw-rw-r-- 1 mpjanic mpjanic 3.8K Feb  5 21:54 3003.vcf
-rw-rw-r-- 1 mpjanic mpjanic 3.8K Feb  5 21:54 3100203.vcf
-rw-rw-r-- 1 mpjanic mpjanic 3.8K Feb  5 21:54 3101801.vcf
-rw-rw-r-- 1 mpjanic mpjanic 3.8K Feb  5 21:54 317155.vcf
-rw-rw-r-- 1 mpjanic mpjanic 3.8K Feb  5 21:54 59386145.vcf
-rw-rw-r-- 1 mpjanic mpjanic 3.9K Feb  5 21:54 59885590.vcf
-rw-rw-r-- 1 mpjanic mpjanic 3.8K Feb  5 21:54 7103002.vcf
-rw-rw-r-- 1 mpjanic mpjanic 3.8K Feb  5 21:54 8072501.vcf
-rw-rw-r-- 1 mpjanic mpjanic 3.8K Feb  5 21:54 8100901.vcf
-rw-rw-r-- 1 mpjanic mpjanic 3.8K Feb  5 21:54 9052004.vcf
-rw-rw-r-- 1 mpjanic mpjanic 3.7K Feb  5 21:54 9070202.vcf
-rw-rw-r-- 1 mpjanic mpjanic 3.7K Feb  5 21:54 9071501.vcf
-rw-rw-r-- 1 mpjanic mpjanic 3.7K Feb  5 21:54 9090701.vcf
-rw-rw-r-- 1 mpjanic mpjanic 3.7K Feb  5 21:54 1401.vcf
```
