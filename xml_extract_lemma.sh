#!/usr/bin/env bash
# Author: Brian Hodge
# @param: XML file from coreNLP lemmatization
# @output: TXT file containing lemmatizations separated by a space

# Use sed to extract text between the <lemma> tags
# let name=$1
sed -n 's:.*<lemma>\(.*\)</lemma>.*:\1:p' $1 > newline.txt

# Use tr to replace newlines with spaces
tr '\n' ' ' < newline.txt > $1_lemma.txt

# Clean up after ourselves - remove files we're done with
rm ../../2004/_*.txt 2> /dev/null
rm ../../2004/*_tags.txt 2> /dev/null
rm ../../2004/*_words.txt 2> /dev/null
rm ../../2004/*_newline.txt 2> /dev/null

rm ../../2005/_*.txt 2> /dev/null
rm ../../2005/*_tags.txt 2> /dev/null
rm ../../2005/*_words.txt 2> /dev/null
rm ../../2005/*_newline.txt 2> /dev/null

rm ../../2006/_*.txt 2> /dev/null
rm ../../2006/*_tags.txt 2> /dev/null
rm ../../2006/*_words.txt 2> /dev/null
rm ../../2006/*_newline.txt 2> /dev/null

rm ../../2007/_*.txt 2> /dev/null
rm ../../2007/*_tags.txt 2> /dev/null
rm ../../2007/*_words.txt 2> /dev/null
rm ../../2007/*_newline.txt 2> /dev/null

rm $1