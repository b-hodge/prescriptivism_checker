#!/bin/bash
# Author: Brian Hodge
# @param: XML file from coreNLP lemmatization
# @output: TXT file containing lemmatizations separated by a space

# Use sed to extract text between the <lemma> tags
# let name=$1
sed -n 's:.*<lemma>\(.*\)</lemma>.*:\1:p' $1 > newline.txt

# Use tr to replace newlines with spaces
tr '\n' ' ' < newline.txt > $1_space.txt