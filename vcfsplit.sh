#!/bin/bash

cat >> script.awk <<EOL

#find a line with CHROM in the vcf file, go through the fields, place in hash h1, key=position, value=field content

/#[CHROM|CHR|chrom|chr]/ { for(i = 1; i <= NF; i++) {h1[i] = \$i}}

#find a line with SNP ID, go through the fields, if field contains 0/1 or 0|1 print het, hash value (sample name), position, content 

/$1/{for(i = 1; i <= NF; i++)  
{if (\$i~/^0[\/\|]1/) printf "Heterozygote\t"h1[i]"\t"i"\t"\$i"\n"}}

#find a line with SNP ID, go through the fields, if field contains 0/0 or 0|0 print ref homo, hash value (sample name), position, content

/$1/{for(i = 1; i <= NF; i++)  
{if (\$i~/^0[\/\|]0/) printf "Reference homozygote\t"h1[i]"\t"i"\t"\$i"\n"};}

#find a line with SNP ID, go through the fields, if field contains 1/1 or 1|1 print ref homo, hash value (sample name), position, content

/$1/{for(i = 1; i <= NF; i++)  
{if (\$i~/^1[\/\|]1/) printf "Alternative homozygote\t"h1[i]"\t"i"\t"\$i"\n"};}
EOL

#run awk script with $2 provided as vcf file

awk -f script.awk $2
