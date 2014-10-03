#!/usr/bin/perl -w
use strict;
use Scalar::Util qw(looks_like_number); #use perl module which checks if var is a number

# http://www.cse.unsw.edu.au/~cs2041/assignments/python2perl
# written by antheny yu z3463699

my %int_variables = ();
my %str_variables = ();
my $control_flows = "(if|while|elif)"; 
my $indent = 0;
my $prev_line = '';
#my $math_ops = "[\=\+\-\*\/]";

while (my $line = <>) {
    if ($indent > 0){
        $line =~ /^(\s*)[a-z]/;
        my $current_indent = $1;
        $prev_line =~ /^(\s*)[a-z]/;
        my $prev_indent = $1; 
        if($prev_indent > $current_indent){
            $indent--;
        }
    }

	if ($line =~ /^#!/ && $. == 1) {
    	print "#!/usr/bin/perl -w\n"; # translate #! line 
	} elsif ($line =~ /^\s*#/ || $line =~ /^\s*$/) {
		print $line; # Blank & comment lines can be passed unchanged
    } elsif ($line =~ /import/){
        print "\n";
    }
    elsif ($line =~ /for/){
        my @values = split(' ',$line);
        $indent++;
        for_routine(@values);  
    }
    elsif ($line =~ /$control_flows/){
        my @values = split(' ', $line);
        my $print_flag = 0;
        my $i = 0;
        while ($i <= $#values){
            my $var = $values[$i];
            if (($i == $#values) && ($var !~ /\:/)){#one line statements, close the bracket
                print looks_like_number($var) ? '' : '$', "$var;\n";
                print "\}\n";
                $indent--;
            } elsif ($var =~ /$control_flows/){
                print ' ' x ($indent*4);
                $indent++;
                my @control_array;
                while($i <= $#values){
                    push(@control_array, $values[$i]);
                    if ($values[$i] =~ /\:/){
                        last;
                    } else {
                        $i++;
                    }
                }
                control_routine(@control_array);
            } elsif ($var =~ /print/) { #special case for 2nd subset
                my @print_array;        #one line programs
                while($i <= $#values){
                    push(@print_array, $values[$i]);
                    if ($values[$i] =~ /\;/){
                        last;
                    } else {
                        $i++;
                    }
                } 
                print_routine(@print_array); 
                if ($i == (1+$#values)) {
                    print "\}\n";   
                    $indent--;
                } else {
                    print ' ' x ($indent*4);
                }
            } elsif($var =~ s/;//){
                print looks_like_number($var) ? '' : '$', "$var\; \n";
            } elsif ($var =~ /[\=\+\-\*\/\>\<\"\']/) { #if the variable is [=+-*/]
                print "$var ";
            } else{
                print looks_like_number($var) ? '' : '$', "$var "; #checks if the variable
            }  
            $i++;
        }
    } 
    elsif ($line =~ /^\s*[a-zA-Z0-9\_]*\s*\=\s*\b[\s0-9\+\-\*\/]*\b/){
        my @values = split(' ',$line); #if the line looks like
        assign_routine(@values);       #var = som * som2 etc...
    } elsif ($line =~ /^\s*print/) {
        my @values = split(' ', $line);
        print_routine(@values);    
    } 
    else {
		# Lines we can't translate are turned into comments
		print "#$line\n";
	}
    $prev_line = $line;
}
if ($indent > 0){
    print "\}";
    $indent--;
}
sub assign_routine {
    my @values = @_;
    print ' ' x ($indent*4);
    for my $i (0 .. $#values){      
        my $var = $values[$i];     #split the line to get numbers & strings
        if(($i eq $#values) && ($var !~ /\=/)){ #last variable on the line
            print looks_like_number($var) ? '' : '$', "$var;\n"; 
        } elsif ($var =~ /[\=\+\-\*\/]/) { #if the variable is [=+-*/]
            print "$var ";
        } else{
            print looks_like_number($var) ? '' : '$', "$var "; #checks if the variable
        }                                                      #is a str or int
    }
}
sub print_routine {
    my @values = @_;
    print ' ' x ($indent*4);
    for my $i (0 .. $#values){
        my $var = $values[$i];
        $var =~ s/\;//;
        if ($#values eq 0){ #if just print, print a new line
            print "print \"\\n\"\n"; 
        } elsif($i eq $#values){ #if last variable in line add ,"\n"; to the end of the line
            if ($var =~ /[\=\+\-\*\/\"\']/) {
                print "$var ";
            } else {
                print looks_like_number($var) ? '' : '$' 
            }
            print ",\"\\n\"\;\n";
        } elsif ($var =~ /[\=\+\-\*\/\"\']/){
            print "$var ";
        } elsif ($var =~ /print/) {
            print "$var ";  
        } else{
            print looks_like_number($var) ? '' : '$', "$var ";
        } #similar approach to as above, split the string when see print 
    }
}

sub control_routine {
    my @values = @_;
    my $i = 0;
    while ($i <= $#values){
        my $var = $values[$i];
        if ($var =~ /$control_flows/){
            print "$var \(";
        }
        elsif ($var =~ /[\=\+\-\*\/\>\<]/) { #if the variable is [=+-*/]
            print "$var ";
        }
        elsif ($var =~ s/\://){
            print looks_like_number($var) ? '' : '$', "$var\)\{\n";
        } else{
            print looks_like_number($var) ? '' : '$', "$var ";
        }
        $i++;
    }
}

sub for_routine {
    my @values = @_;
    my $i = 0;
    while ($i <= $#values){
        my $var = $values[$i];
        if($var =~ /for/){
            print "for ";
        } elsif ($var =~ s/\)\://){
            $var -= 1;
            print looks_like_number($var) ? '' : '$', "$var\)\{\n";
        } elsif ($var =~ s/range\((.*)\,//) {
            print looks_like_number($1) ? '' : '$', "\($1 .. ";
        } elsif ($var =~ /in/){
            print '';
        }



        else {
            print looks_like_number($var) ? '' : '$', "$var ";
        }
        $i++;
    }
}
