# Author: Brian Hodge
# Last Modified: March 21, 2016

# Best practices
use strict;
use warnings;

# Use Tie for outputting to CSV
use Tie::Array::CSV;

# Output to "prescriptivism_output.csv" in the root project directory
my $output_filename = '../prescriptivism_output.csv';

my @words;
my @tags;

# file processing handling
my $filename = $ARGV[0];
my $stem_filename = $ARGV[1];
my $essay_id = $ARGV[2];

my $entire_file;
open(my $filehandle, '<', $filename) or die "Could not open $filename\n";
{
    local $/;
    $entire_file = <$filehandle>;
}
# Reset $filehandle
seek $filehandle, 0, 0;

# Split original file on " " into array @resultarray
my @resultarray;
while(my $line = <$filehandle>) {
	chomp $line;
	my @linearray = split(" ", $line);
	push(@resultarray, @linearray);
}
#print("$resultarray[0]\n");

# Open the stemmed file
open(my $stem_filehandle, '<', $stem_filename) or die "Could not open $stem_filename\n";

# Split stemmed file on " " into array @stemresultarray
my @stemresultarray;
while (my $line = <$stem_filehandle>) {
	chomp $line;
	# Note the scope of @linearray - no conflict with reuse
	my @linearray = split(" ", $line);
	push(@stemresultarray, @linearray);
}
#print("@stemresultarray\n");




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
# Number of sentences = number of '.' tags + '?' tags + '!' tags
$numSentences += $tagfreq{'.'} + $tagfreq{'?'} + $tagfreq{'!'};

# Number of punctuation tokens
$numPunctuation += $numSentences + $tagfreq{','} + $tagfreq{':'} + $tagfreq{';'} + $tagfreq{'-'} + $tagfreq{'('} + $tagfreq{')'};

# Number of words = number of entries in @words - $numPunctuation
$numWords += (@words - $numPunctuation);

# PROGRESSIVE VERB FORMS FREQUENCY 

my $progVerb = 0;
if (exists($tagfreq{'VVG'})) {
	$progVerb += $tagfreq{'VVG'};
}

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

keys %tagfreq; # reset the internal iterator
while(my($k, $v) = each %tagfreq) {
    my $first_letter_of_key = substr($k, 0, 1);
    if($first_letter_of_key eq 'N') {
        $nouniness += $v;
    }
}


# VERBINESS

my $verbiness = 0;

keys %tagfreq;
while(my($k, $v) = each %tagfreq) {
    my $first_letter_of_key = substr($k, 0, 1);
    if($first_letter_of_key eq 'V') {
        $verbiness += $v;
    }
}


# NP COMPLEXITY
#my $avgNGramLength = 0;
#my $longest = "";
#my $longestLength = 0;
#my $secondLongest = "";
#my $secondLongestLength = 0;
#my $thirdLongest = "";
#my $thirdLongestLength = 0;
#my $numGrams = 0;
#my $totalGramLength = 0;
#my $ngram = "";
#
#my $j = 1;
#for my $i (0 .. @matrix-1) {
#	my $ngram = "";
#	$j = 1;
#	if($matrix[$i][1] eq '.' && substr($matrix[$i-1][1], 0, 1) eq 'N') {
#		while((substr($matrix[$i-$j][1], 0, 1) eq 'N' || (substr($matrix[$i-$j][1], 0, 1) eq 'J'))) {
#			$ngram = "$matrix[$i-$j][0]" . " " . "$ngram";
#			++$j;
#		}
#	}
#
#	if ($j > 1) {
#		++$numGrams;
#		$totalGramLength += $j;
#	}
#
#	if($j-1 > $longestLength) {
#		$longest = $ngram;
#		$longestLength = $j-1;
#	}
#	elsif($j-1 > $secondLongestLength) {
#		$secondLongest = $ngram;
#		$secondLongestLength = $j-1;
#	}
#	elsif($j-1 > $thirdLongestLength) {
#		$thirdLongest = $ngram;
#		$thirdLongestLength = $j-1;
#	}
#}
#$avgNGramLength = $totalGramLength / $numGrams;

# CONTRACTIONS
# POTENTIAL REFACTOR: count occurrences of "'", excluding possessives
my $apostrophe_count = $entire_file =~ tr/\'//;
my $numContractions = $apostrophe_count - $tagfreq{'GE'};


# Contractions can end with either "n't", "'s", or "'d"
#my $contTotal = 0;
#my $ntCount = 0;
#my $sCount = 0;
#my $dCount = 0;
## All "n't" endings are contractions
## $ntCount
#if (exists($wordfreq{'n\'t'})) {
#	$ntCount += $wordfreq{'n\'t'};
#}
#
## "'s" endings are contractions if their tag starts with "V"
## $sCount
#keys %combofreq; #reset internal iterator
#while(my($k, $v) = each %combofreq) {
#    # Split $k on "_"
#    @split_key = split(/_/, $k);
#    if ($split_key[0] eq '\'s') {
#        if (substr($split_key[1], 0, 1) eq 'V') {
#            $sCount += $v;
#        }
#    }
#}
#
## $dCount
#if (exists($wordfreq{'\'d'})) {
#	$dCount += $wordfreq{'\'d'};
#}
#
#$contTotal = $ntCount + $sCount + $dCount;

# LOOP FOR PREPOSITIONS
my $totalPrep = 0;
my $finalPrep = 0;
for(my $k = 0; $k < @resultarray-1; $k++) {
	if ($tags[$k] eq "II" || $tags[$k] eq "IF" || $tags[$k] eq "IO" || $tags[$k] eq "IW") {
		if ($tags[$k + 1] eq "." || $tags[$k + 1] eq '!' || $tags[$k + 1] eq '?') {
			$finalPrep++;
		}
		$totalPrep++;
	}	
}

# PIED PIPING
my $ppTag = "";
my $ppNum = 0;
for my $i (0 .. @matrix-1) {
	$ppTag = "";
	$ppTag = $matrix[$i][1];
	if ($ppTag eq 'II' || $ppTag eq 'IF' || $ppTag eq 'IO' || $ppTag eq 'IW') {
		if (($matrix[$i+1][1] eq 'PNQO') || ($matrix[$i+1][1] eq 'PNQS') || ($matrix[$i+1][1] eq 'DDQGE') || ($matrix[$i+1][1] eq 'DDQ')) {
			if ($i > 0 && not ($matrix[$i-1][1] eq ',')) {
				++$ppNum;
			}
		}
	}
}
#$ppNum = $ppNum / $verbiness;



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

# HYPERCORRECT WHOM
my $numHyperWhom = 0;
if (exists($wordfreq{'whom'}) || exists($wordfreq{'Whom'})) {
	for(my $k = 0; $k < @resultarray; $k++) {
		if ($words[$k] eq "whom" || $words[$k] eq 'Whom') {
			my $first_letter_of_tag = substr($tags[$k+1], 0, 1);
                        if ($first_letter_of_tag eq 'V') {
                            if (not ($tags[$k+1] eq 'VBI' || $tags[$k+1] eq 'VDI' || $tags[$k+1] eq 'VHI' || $tags[$k+1] eq 'VVI')) {
                                $numHyperWhom++;
                            }
                        }
                }
	}
}


# HOPEFULLY
my $numClauseInitialHopefully = 0;
# We want to count the num occurrences of "hopefully" where it is NOT preceded by a verb
# Set of verb tags: VB, VBD, VBG, VBN, VBP, VBZ
if (exists($wordfreq{'hopefully'}) || exists($wordfreq{'Hopefully'})) {
	for(my $k = 0; $k < @resultarray; $k++) {
		if ($words[$k] eq 'hopefully' || $words[$k] eq 'Hopefully') {
                        if ($k == 0 || substr($tags[$k-1], 0, 1) ne 'V') {
                            $numClauseInitialHopefully++;
                        }
		}
	}
}

# THE THAT-RULE
# We want:
#   a) - Number of occurrences of "that" as a restrictive relativizer
#   b) - Number of occurrences of "which" as a restrictive relativizer
my $that_restrictive = 0;
if (exists($wordfreq{'that'}) || exists($wordfreq{'That'})) {
    for (my $k = 0; $k < @resultarray; $k++) {
        if ($words[$k] eq 'that' || $words[$k] eq 'That') {
            if ($tags[$k] eq 'DD1' && $k != 0) {
                if ($words[$k-1] eq ',') {
                    $that_restrictive += 1;
                }
            }
        }
    }
}

my $which_restrictive = 0;
if (exists($wordfreq{'which'}) || exists($wordfreq{'Which'})) {
    for (my $k = 0; $k < @resultarray; $k++) {
        if ($words[$k] eq 'which' || $words[$k] eq 'Which') {
            if ($tags[$k] eq 'DDQ' && $k != 0) {
                if ($words[$k-1] eq ',') {
                    $that_restrictive += 1;
                }
            }
        }
    }
}

# DON'T SPLIT INFINITIVES
# We want number of occurrences of 'to' as an infinitive marker, but NOT followed by a VVI-tagged verb
my $num_split_infinitives = 0;
for (my $k = 0; $k < @resultarray-1; $k++) {
    if (tags[$k] eq 'TO' && tags[$k+1] ne 'VVI') {
        $num_split_infinitives += 1;
    }
}


###################################################################################
#																				  #
#	STEMMING VARIABLES															  #
#																				  #
###################################################################################

# TTR
my $ttr1 = 0;
my $ttr2 = 0;
my $ttr3 = 0;
my $slope1 = 0;
my $slope2 = 0;
my %window1_hash;
my %window2_hash;
my %window3_hash;

# First check that the sample is long enough
if(@stemresultarray < 150) {
	print "Sample not long enough for TTR.\n";
	print "Writing 'NA' instead.\n";
	$ttr1 = "NA";
	$ttr2 = "NA";
	$ttr3 = "NA";
	$slope1 = "NA";
	$slope2 = "NA";

} else {	# else calculate TTR!
	# Set up hashes for each window
	foreach(@resultarray[0..49]) {
		$window1_hash{$_}++;
	}
	foreach(@resultarray[50..99]) {
		$window2_hash{$_}++;
	}
	foreach(@resultarray[99..149]) {
		$window3_hash{$_}++;
	}

	# Calculate TTRs
	# Note that # of tokens is ALWAYS 50
	$ttr1 = (keys %window1_hash) / 50;
	$ttr2 = (keys %window2_hash) / 50;
	$ttr3 = (keys %window3_hash) / 50;
}

# MODALITY
# We want num. occurrences of the following constructions:
#	need(s/ed) to
#	have(has/had) to
#	must
#	ought to
#	should

my $numNeedTo = 0;
my $numHaveTo = 0;
my $numMust = 0;
my $numOughtTo = 0;
my $numShould = 0;

# Find every occurrence of 'need' in the stemmed array, and if it's followed by 'to', increment
for(my $k = 0; $k < @stemresultarray; $k++) {
	if ($stemresultarray[$k] eq "need" || $stemresultarray[$k] eq "Need") {
		# Make sure we're not going to read past the end of the array
		if ($k != @stemresultarray-1) {
			if ($stemresultarray[$k+1] eq "to") {
				$numNeedTo++;
			}
		}	
	}	
}

# Find every occurrence of 'have' in the stemmed array, and if it's followed by 'to', increment
for(my $k = 0; $k < @stemresultarray; $k++) {
	if ($stemresultarray[$k] eq "have" || $stemresultarray[$k] eq "Have") {
		# Make sure we're not going to read past the end of the array
		if ($k != @stemresultarray-1) {
			if ($stemresultarray[$k+1] eq "to") {
				$numHaveTo++;
			}
		}	
	}	
}

# Find every occurrence of 'must' in the stemmed array, increment
for(my $k = 0; $k < @stemresultarray; $k++) {
	if ($stemresultarray[$k] eq "must" || $stemresultarray[$k] eq "Must") {
		$numMust++;
	}	
}

# Find every occurrence of 'ought' in the stemmed array, and if it's followed by 'to', increment
for(my $k = 0; $k < @stemresultarray; $k++) {
	if ($stemresultarray[$k] eq "ought" || $stemresultarray[$k] eq "Ought") {
		# Make sure we're not going to read past the end of the array
		if ($k != @stemresultarray-1) {
			if ($stemresultarray[$k+1] eq "to") {
				$numOughtTo++;
			}
		}	
	}	
}

# Find every occurrence of 'should' in the stemmed array, increment
for(my $k = 0; $k < @stemresultarray; $k++) {
	if ($stemresultarray[$k] eq "should" || $stemresultarray[$k] eq "Should") {
		$numShould++;
	}	
}

# ACTIVE VOICE
# We want num. occurrences of the following construction:
#	A conjugated form of BE followed by a VBN tag
# Output this number divided by verbiness

# First, find every occurrence of "be" in stemresultarray
my $numPassive = 0;
my $numPassiveNormalized = 0;
for(my $k = 0; $k < @stemresultarray; $k++) {
	if ($stemresultarray[$k] eq "be" || $stemresultarray[$k] eq "Be") {
		# Make sure we're not going to read past the end of the array
		if ($k != @stemresultarray-1) {
			# If that occurrence of "be" is followed by a VVN tag, 
			# we've found a passive voice construction
			if ($tags[$k+1] eq "VVN") {
				$numPassive++;
			}
		}
	}
}
$numPassiveNormalized = $numPassive / $verbiness;

###################################################################################
#																				  #
#	PRINT TO FILE															  	  #
#																				  #
###################################################################################

tie my @output, 'Tie::Array::CSV', $output_filename;
push(@output, [$essay_id, $numWords, $numSentences, $progVerb, $avgWordLength, $avgSentenceLength,
$nouniness, $verbiness, $numContractions, $totalPrep, $finalPrep, $ppNum, $numComprisedOf, $numShall,
$numHyperWhom, $that_restrictive, $which_restrictive, $num_split_infinitives, $ttr1, $ttr2, $ttr3, $numNeedTo, $numHaveTo, $numMust, $numOughtTo,
$numShould, $numClauseInitialHopefully, $numPassive, $numPassiveNormalized]);
untie @output;

# OUTPUT TO STD OUT

# print "essay_id = $essay_id\n";
# print "numWords = $numWords\n";
# print "numSentences = $numSentences\n";
# print "progVerb = $progVerb\n";
# print "Avg word length = $avgWordLength\n";
# print "Avg sentence length = $avgSentenceLength\n";
# print "nouniness = $nouniness\n";
# print "verbiness = $verbiness\n";
# print "NP COMPLEXITY:\n";
# print "Average n-gram length = $avgNGramLength\n";
# print "Length of longest n-gram = $longestLength\n";
# print "Longest n-gram: $longest\n";
# print "Second longest n-gram: $secondLongest\n";
# print "Third longest n-gram: $thirdLongest\n";
# print "contractions count = $contTotal\n";
# print "total number of prepositions = $totalPrep\n";
# print "sentence final prepositions = $finalPrep\n";
# print "Occurrences of 'Comprised of' = $numComprisedOf\n";
# print "Occurrences of 'shall' = $numShall\n";
# print "Instances of hyper-correct whom = $numHyperWhom\n";
# print "TTR for window 1 = $ttr1\n";
# print "TTR for window 2 = $ttr2\n";
# print "TTR for window 3 = $ttr3\n";
# print "numNeedTo = $numNeedTo\n";
# print "numHaveTo = $numHaveTo\n";
# print "numMust = $numMust\n";
# print "numOughtTo = $numOughtTo\n";
# print "numShould = $numShould\n";
# print "numClauseInitialHopefully = $numClauseInitialHopefully\n";
# print "numPassive = $numPassive\n";
# print "numPassiveNormalized = $numPassiveNormalized\n";
