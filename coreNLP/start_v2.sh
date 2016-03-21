#!/usr/bin/env bash

#  start_claws.sh
#  
#
#  Created by Brian Hodge on 2/26/16.
#

# Build dir_list files
ls ../../2004 > ../dir_list/dir_list_2004.txt
sed -i -e 's*^*../../2004/*' ../dir_list/dir_list_2004.txt
ls ../../2005 > ../dir_list/dir_list_2005.txt
sed -i -e 's*^*../../2005/*' ../dir_list/dir_list_2005.txt
ls ../../2006 > ../dir_list/dir_list_2006.txt
sed -i -e 's*^*../../2006/*' ../dir_list/dir_list_2006.txt
ls ../../2007 > ../dir_list/dir_list_2007.txt
sed -i -e 's*^*../../2007/*' ../dir_list/dir_list_2007.txt

# Run coreNLP lemmatizer on files in each of our 4 directories (2004, 2005, 2006, 2007)
./lemmatize_in_list.sh

# Prepare essay files for tagging by wrapping them in <text></text> tags
# Run CLAWS tagger on files in each of the 4 directories
./tag_in_list.sh

#Extract lemma data from the XML files in each directory
for f in ../../2004/*.xml
do
    ../xml_extract_lemma.sh $f
done

for f in ../../2005/*.xml
do
    ../xml_extract_lemma.sh $f
done

for f in ../../2006/*.xml
do
    ../xml_extract_lemma.sh $f
done

for f in ../../2007/*.xml
do
    ../xml_extract_lemma.sh $f
done

#At this point, each directory should contain:
#The original files,
#POS-tagged versions of the original files, ending in .c7
#CLAWS supplemental files, ending in .c7.supp
#Lemmatized versions of the original files, ending in _lemma.txt

#Run Convert to move from vertical -> horizontal output
#Remove "^" from horizontal output
#Remove newlines from horizontal output
#Run analysis

# for f in $(cat ../dir_list/dir_list_2004.txt ../dir_list/dir_list_2005.txt ../dir_list/dir_list_2006.txt ../dir_list/dir_list_2007.txt)
# do
#     ./convert -v2hsupp $f.c7 $f.hrz $f.c7.supp
#     sed 's/\^ //' $f.hrz > $f.hrz
#     tr -d '\n' < $f.hrz
#     perl ../pchecker.pl $f.hrz $f.xml_lemma.txt ${f:11}
#     rm $f.hrz
#     rm $f.xml_lemma.txt
# done
