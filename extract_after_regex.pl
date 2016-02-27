use strict;
use warnings;
use autodie;

open my $infh, '<', 'example.txt.c7';
open my $outfh, '>', 'example.txt.c7.tagged';

while (my $line = <$infh>) {
    chomp $line;
    get_word_match($line);
}

sub get_word_match {
	my $line = shift;
    
    if ( $line =~ /(\b[a-z.,!?]+\b)/i ) {
        my $word = $1;
        print $outfh, $word;
        print $outfh, "_";
        
        my $regex = qr/^.+(\b[a-z]+\b)/i;
        my $replace = "";
        my $input =~ s/$regex/$replace/;
        get_tag_match($input);
    }
    
    
}

sub get_tag_match {
    my $remainder = shift;
    
    if ( $remainder =~ /(\b(?!ERROR\?)[a-z.,!]+[0-9]*)/i ) {
        my $tag = $1;
        print $outfh, $tag;
        print $outfh, " ";
    }
    
}

