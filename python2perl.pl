#!/usr/bin/perl
use strict;
use Scalar::Util qw(looks_like_number);
# http://www.cse.unsw.edu.au/~cs2041/assignments/python2perl
# written by antheny yu z3463699

my %int_variables = ();
my %str_variables = ();

while (my $line = <>) {
	if ($line =~ /^#!/ && $. == 1) {
    	print "#!/usr/bin/perl -w\n"; # translate #! line 
	} elsif ($line =~ /^\s*#/ || $line =~ /^\s*$/) {
		print $line; # Blank & comment lines can be passed unchanged
	} elsif ($line =~ /^\s*[a-zA-Z0-9\_]*\s*\=\s*\b[\s0-9\+\-\*\/]*\b/){
        my @values = split(' ',$line); #if the line looks like
        for my $i (0 .. $#values){     #var = som * som2 etc...
            my $var = $values[$i];     #split the line to get numbers & strings
            if(($i eq $#values) && ($var !~ /\=/ )){ #last variable on the line
                print looks_like_number($var) ? '' : '$', "$var;\n"; 
            } elsif ($var =~ /[\=\+\-\*\/]/) { #if the variable is [=+-*/]
                print "$var ";
            } else{
                print looks_like_number($var) ? '' : '$', "$var "; #checks if the variable
            }                                                      #is a str or int
        }
    } elsif ($line =~ /^\s*print/){
        my @values = split(' ', $line);
        for my $i (0 .. $#values){
            my $var = $values[$i];
            if($i eq $#values){
                print looks_like_number($var) ? '' : '$',"$var,\"\\n\"\;\n";
            } elsif ($var =~ /[\=\+\-\*\/]/){
                print "$var ";
            } elsif ($var =~ /print/) {
                print "$var ";  
            } else{
                print looks_like_number($var) ? '' : '$', "$var "; #checks if the variable
            }  
        }
        #print "print \"\$$1\\n\"\;\n";
    } 
    
    else {
		# Lines we can't translate are turned into comments
		print "#$line\n";
	}
}


