# Author: Brian Hodge
# Last Modified: Nov 20, 2015

use strict;
use warnings;

my @words;
my @tags;

# file processing handling
my $filename = $ARGV[0];
my $stem_filename = $ARGV[1];
open(my $filehandle, '<', $filename) or die "Could not open $filename\n";

# Split on " " into array @resultarray
my @resultarray;
while(my $line = <$filehandle>) {
	chomp $line;
	my @linearray = split(" ", $line);
	push(@resultarray, @linearray);
}
#print("$resultarray[0]\n");

###################################################################################
#																				  #
#	BUILD DATA STRUCTURES										  			      #
#																				  #
###################################################################################

# Split on "_" into two arrays, @words and @tags
# Also create the 2d array '@matrix'
my @matrix;
foreach (@resultarray) {
	my @separated = split('_', $_);
	push (@words, $separated[0]);
	push (@tags, $separated[1]);
	push (@matrix, \@separated);
}

# Create a combined frequency hash of words and tags
my %combofreq;
for(@resultarray) {
	$combofreq{$_}++;
}

#Convert @words into a frequency hash
my %wordfreq;
for(@words) {
	$wordfreq{$_}++;
}

# Convert @tags into a frequency hash
my %tagfreq;
for (@tags) {
	$tagfreq{$_}++;
}
# Print statements for debugging

#print("\n");
#print("COMBO FREQUENCY HASH\n");
#print("\n");
#foreach my $str (sort keys %combofreq) {
#	printf"%-31s %s\n", $str, $combofreq{$str};
#}

#print("\n");
#print("TAG FREQUENCY HASH\n");
#print("\n");
#foreach my $str (sort keys %tagfreq) {
#	printf"%-31s %s\n", $str, $tagfreq{$str};
#}

#print("\n");
#print("WORD FREQUENCY HASH\n");
#print("\n");
#foreach my $str (sort keys %wordfreq) {
#	printf"%-31s %s\n", $str, $wordfreq{$str};
#}


###################################################################################
#																				  #
#	START COMPUTING VARIABLES													  #
#																				  #
###################################################################################

# TEXT-SAMPLE STATS

my $numWords = 0;
my $numSentences = 0;
my $numPunctuation = 0;
# Number of sentences = number of '.' tags (includes all full-stops)
if (exists($tagfreq{'.'})) {
	$numSentences += $tagfreq{'.'};
}
# Number of punctuation tokens
if (exists($tagfreq{'.'})) {
	$numPunctuation += $tagfreq{'.'};
}
if (exists($tagfreq{','})) {
	$numPunctuation += $tagfreq{','};
}
if (exists($tagfreq{':'})) {
	$numPunctuation += $tagfreq{':'};
}
if (exists($tagfreq{'"'})) {
	$numPunctuation += $tagfreq{'"'};
}
if (exists($tagfreq{'``'})) {
	$numPunctuation += $tagfreq{'``'};
}

# Number of words = number of entries in @words - $numPunctuation
$numWords += (@words - $numPunctuation);

# PROGRESSIVE VERB FORMS FREQUENCY 

my $progVerb = 0;
if (exists($tagfreq{'VBG'})) {
	$progVerb += $tagfreq{'VBG'};
}

# AVG WORD LENGTH
# Avg word length = (total num characters - punctuation - spaces - carriage returns) / numWords

my $avgWordLength = 0;
for(@words) {
	$avgWordLength += length($_);
}
$avgWordLength -= ($numPunctuation + $numWords + $numSentences);
$avgWordLength = $avgWordLength / $numWords;
# AVG SENTENCE LENGTH
my $avgSentenceLength = $numWords / $numSentences;

# NOUNINESS

my $nouniness = 0;
if (exists($tagfreq{'NN'})) {
	$nouniness += $tagfreq{'NN'};
}
if (exists($tagfreq{'NNP'})) {
	$nouniness += $tagfreq{'NNP'};
}
if (exists($tagfreq{'NNPS'})) {
	$nouniness += $tagfreq{'NNPS'};
}
if (exists($tagfreq{'NNS'})) {
	$nouniness += $tagfreq{'NNS'};
}

# VERBINESS

my $verbiness = 0;
if (exists($tagfreq{'VB'})) {
	$verbiness += $tagfreq{'VB'};
}
if (exists($tagfreq{'VBD'})) {
	$verbiness += $tagfreq{'VBD'};
}
if (exists($tagfreq{'VBG'})) {
	$verbiness += $tagfreq{'VBG'};
}
if (exists($tagfreq{'VBN'})) {
	$verbiness += $tagfreq{'VBN'};
}
if (exists($tagfreq{'VBP'})) {
	$verbiness += $tagfreq{'VBP'};
}
if (exists($tagfreq{'VBZ'})) {
	$verbiness += $tagfreq{'VBZ'};
}

# MODALITY

# NP COMPLEXITY
my $avgNGramLength = 0;
my $longest = "";
my $longestLength = 0;
my $secondLongest = "";
my $secondLongestLength = 0;
my $thirdLongest = "";
my $thirdLongestLength = 0;
my $numGrams = 0;
my $totalGramLength = 0;
my $ngram = "";

my $j = 1;
for my $i (0 .. @matrix-1) {
	my $ngram = "";
	$j = 1;
	if($matrix[$i][1] eq '.' && substr($matrix[$i-1][1], 0, 1) eq 'N') {
		while((substr($matrix[$i-$j][1], 0, 1) eq 'N' || (substr($matrix[$i-$j][1], 0, 1) eq 'J'))) {
			$ngram = "$matrix[$i-$j][0]" . " " . "$ngram";
			++$j;
		}
	}

	if ($j > 1) {
		++$numGrams;
		$totalGramLength += $j;
	}

	if($j-1 > $longestLength) {
		$longest = $ngram;
		$longestLength = $j-1;
	}
	elsif($j-1 > $secondLongestLength) {
		$secondLongest = $ngram;
		$secondLongestLength = $j-1;
	}
	elsif($j-1 > $thirdLongestLength) {
		$thirdLongest = $ngram;
		$thirdLongestLength = $j-1;
	}
}
$avgNGramLength = $totalGramLength / $numGrams;

# CONTRACTIONS
my $contTotal = 0;
my $ntCount = 0;
my $sCount = 0;
my $dCount = 0;
# $ntCount
if (exists($wordfreq{'n\'t'})) {
	$ntCount += $wordfreq{'n\'t'};
}

# $sCount
if (exists($combofreq{'\'s_VB'})) {
	$sCount += $combofreq{'\'s_VB'};
}
if (exists($combofreq{'\'s_VBD'})) {
	$sCount += $combofreq{'\'s_VBD'};
}
if (exists($combofreq{'\'s_VBG'})) {
	$sCount += $combofreq{'\'s_VBG'};
}
if (exists($combofreq{'\'s_VBN'})) {
	$sCount += $combofreq{'\'s_VBN'};
}
if (exists($combofreq{'\'s_VBP'})) {
	$sCount += $combofreq{'\'s_VBP'};
}
if (exists($combofreq{'\'s_VBZ'})) {
	$sCount += $combofreq{'\'s_VBZ'};
}

# $dCount
if (exists($wordfreq{'\'d'})) {
	$dCount += $wordfreq{'\'d'};
}

$contTotal = $ntCount + $sCount + $dCount;

# ACTIVE VOICE
#my $numPassive = 0;
#my $activeString = "";
#for my $i (0 .. @matrix-1) {
#	$activeString = $matrix[$i][0];
#	if (($activeString eq 'am') || ($activeString eq 'are') || ($activeString eq 'is')
#		|| ($activeString eq 'was') || ($activeString eq 'were') || ($activeString eq 'been')
#		|| ($activeString eq 'be') || ($activeString eq 'being')) {
#		if ()
#	}
	
#}

# LOOP FOR PREPOSITIONS
my $totalPrep = 0;
my $finalPrep = 0;
for(my $k = 0; $k < @resultarray; $k++) {
	if ($tags[$k] eq "IN") {
		if ($tags[$k + 1] eq ".") {
			$finalPrep++;
		}
		$totalPrep++;
	}	
}

# # PIED PIPING
# my $ppTag = "";
# my $ppNum = 0;
# for my $i (0 .. @matrix-1) {
# 	$ppTag = "";
# 	$ppTag = $matrix[$i][1];
# 	if ($ppTag eq 'IN') {
# 		if (($matrix[$i+1][1] eq 'WDT') || ($matrix[$i+1][1] eq 'WP') ($matrix[$i+1][1] eq 'WP$')) {
# 			if ($i > 0 && not ($matrix[$i-1][1] eq ',')) {
# 				++$ppNum;
# 			}
# 		}
# 	}
# }
#$ppNum = $ppNum / $verbiness;

# # SPLIT INFINITIVES
# # NEEDS TO BE FINISHED
# my $infTag = "";
# my $infString = "";
# my $numInf = 0;
# for my $i (0 .. @matrix-1) {
# 	$infTag = "";
# 	$infString = "";
# 	$infTag = $matrix[$i+1][0];
# 	if ($infTag eq 'VB') {
# 		$infString = $matrix[$i][1];
# 		if (not $infString eq 'to') {
			
# 		}
# 	}
# }

#COMPRISED OF

my $numComprisedOf = 0;
if (exists($wordfreq{'comprised'}) || exists($wordfreq{'Comprised'})) {
	for(my $k = 0; $k < @resultarray; $k++) {
		if ($words[$k] eq "comprised" || $words[$k] eq "Comprised") {
			if ($words[$k + 1] eq "of") {
			$numComprisedOf++;
			}
		}	
	}
}

#SHALL
my $numShall = 0;
if (exists($wordfreq{'shall'}) || exists($wordfreq{'Shall'})) {
	for(my $k = 0; $k < @resultarray; $k++) {
		if ($words[$k] eq "shall" || $words[$k] eq "Shall") {
			$numShall++;
		}	
	}
}

print "numWords = $numWords\n";
print "numSentences = $numSentences\n";
print "progVerb = $progVerb\n";
print "Avg word length = $avgWordLength\n";
print "Avg sentence length = $avgSentenceLength\n";
print "nouniness = $nouniness\n";
print "verbiness = $verbiness\n";
print "NP COMPLEXITY:\n";
print "Average n-gram length = $avgNGramLength\n";
print "Length of longest n-gram = $longestLength\n";
print "Longest n-gram: $longest\n";
print "Second longest n-gram: $secondLongest\n";
print "Third longest n-gram: $thirdLongest\n";
print "contractions count = $contTotal\n";
print "total number of prepositions = $totalPrep\n";
print "sentence final prepositions = $finalPrep\n";
print "Occurrences of 'Comprised of' = $numComprisedOf\n";
print "Occurrences of 'shall' = $numShall\n"