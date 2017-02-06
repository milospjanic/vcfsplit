# vcfsplit


```sh
#!/bin/bash

#separate header into header.txt
awk '/##/ { print }' $1 > header.txt

#separate rest of the file to body.txt
awk '!/##/ { print }' $1 > body.txt

#tab separate body
wget https://raw.githubusercontent.com/milospjanic/tabsep/master/tabsep.sh
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
