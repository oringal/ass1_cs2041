#!/usr/bin/perl -w
use strict;
use Scalar::Util qw(looks_like_number); #use perl module which checks if var is a number

# http://www.cse.unsw.edu.au/~cs2041/assignments/python2perl
# written by antheny yu z3463699

my %array_vars;
my %hash_vars;

my $control_flows = "(if|while|elif)"; 
my @indent;
my $prev_line = '';
my $math_ops = "[\=\+\-\/\"\'\<\>\%\*]";

while (my $line = <>) {
    
    #determine if a control statement has concluded
    #by processing if the indentation level has changed
    #from the previous line
	close_brackets($line, $prev_line); 

	if ($line =~ /^#!/ && $. == 1) {
    	print "#!/usr/bin/perl -w\n"; # translate #! line 
	} elsif ($line =~ /^\s*#/ || $line =~ /^\s*$/) {
		print $line; # Blank & comment lines can be passed unchanged
    } elsif ($line =~ /import/){
        print "\n";
    }
    elsif ($line =~ /for/){
        create_indent();
        process_indent($line);
        my @values = split(' ',$line);
        for_routine(@values);  
    }
    elsif ($line =~ /$control_flows/){
        my @values = split(/[:;]/, $line);
        print scalar(@values), "---\n";
        my $print_flag = 0;
        my $i = 0;
        while ($i <= $#values){
            my $var = $values[$i];
            if (($i == $#values) && ($var !~ /\:/)){#one line statements, close the bracket
                print looks_like_number($var) ? '' : '$', "$var;\n";
                print "\}\n";
                my $popped = pop @indent;
            } elsif ($var =~ /$control_flows/){ 
                my @control_array = split(' ',$var); 
                create_indent();
                process_indent($line);
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
                create_indent(); 
                print_routine(@print_array); 
                if ($i == (1+$#values)) {
                    print "\}\n";   
                    #$indent--;
                    my $popped = pop @indent;
                } else {
                    create_indent();
                }
            } elsif($var =~ s/;//){
                print looks_like_number($var) ? '' : '$', "$var\; \n";
            } elsif ($var =~ /$math_ops/) { #if the variable is [=+-*/]
                print "$var ";
            } else{
                print looks_like_number($var) ? '' : '$', "$var ";
            }  
            $i++;
        }
    } 
    #elsif ($line =~ //){
    #    
    #
    #}

    elsif ($line =~ /^\s*print/) {
        create_indent();
        if ($line =~ /\s*\"\s*\%\s*/){ #use perl printf
            printf_routine($line);
        } else { 
            my @values = split(' ', $line);
            print_routine(@values); #use perl normal print 
        }
    } 
    elsif ($line =~ /sys\.stdout\.write\((.*)\)/){
        create_indent();
        print "print $1\;\n";
    } elsif ($line =~ /sys\.stdin\.readlines/){
        create_indent();
        stdin_readLines_routine($line);
    }
    elsif ($line =~ /len\(\w+\)/){
        create_indent();
        length_routine($line);
    }
    elsif ($line =~ /sys\.stdin\.readline\(\)/){
        my @values = split(' ', $line);
        create_indent();
        assign_routine(@values);
    }
    elsif ($line =~ /else\:/){
        create_indent(); 
        process_indent($line);
        else_routine();
    } elsif ($line =~ /break/){
        create_indent();
        print "last\;\n"
    }
    elsif ($line =~ /^\s*[a-zA-Z0-9\_]*\s*\=\s*\b[\s0-9\+\-\*\/]*\b/){
        my @values = split(' ',$line); #if the line looks like
        create_indent();
        assign_routine(@values);       #var = som * som2 etc...
    }   
         
    else {
		# Lines we can't translate are turned into comments
		print "#$line\n";
	}
    $prev_line = $line;
}
if (scalar(@indent) > 0){ #for the one line while statements i.e. set 2
    print "\}";           #completes the bracket
}

#================================== FUNCTIONS START HERE =====================================

sub create_indent{                   #i got tired of typing the statement
    print ' ' x (scalar(@indent)*4); #so i made it a function
}
sub process_indent{ #when sees a c/f statement (if while for etc...)
    my $line = shift @_;    #pushes to the indent array the length of the indent
    $line =~ /^(\s*)[a-z]/;
    my $current_indent = length($1);
    push(@indent, $current_indent);
}
sub calc_indent{ #takes indent array 
    my $result = 0; #calculates how large the previous indent is. 
    foreach my $i (@indent){
        $result += $i;
    }
    return $result;
}
sub assign_routine {
    my @values = @_;
    for my $i (0 .. $#values){      
        my $var = $values[$i];     #split the line to get numbers & strings
        if($i eq $#values){ #last variable on the line
            if ($var =~ /sys\.stdin\.readline\(\)/){
                print "\<STDIN\>\;\n";
            } else {
                print looks_like_number($var) ? '' : '$', "$var;\n"; 
            }
        } elsif ($var =~ /$math_ops/) { #if the variable is [=+-*/]
            print "$var ";
        }
        
        else{
            print looks_like_number($var) ? '' : '$', "$var "; #checks if the variable
        }                                                      #is a str or int
    }
}
sub close_brackets{
	my $line = shift @_;
	my $prev_line = shift @_;

    #this part calculates the closing brackets
    if(scalar(@indent) > 0){
        my $indent_len = calc_indent(); #get the length of the longest indent 

        #get the length of curr and prev lines indent
        $line =~ /^(\s*)[a-z]/;
        my $current_indent = length($1);
        $prev_line =~ /^(\s*)[a-z]/;
        my $prev_indent = length($1); 

        if($prev_indent > $current_indent){ #at least one control statement has concluded
            while(($indent_len >= $current_indent) && (scalar(@indent)>0)){
                my $popped = pop @indent; #in python indents dont have to be the same length
                $indent_len -= $popped;   #to legally work, but the statement has to be on
                create_indent();          #the same level as a previous indent to work
                print "\}\n"; #loop and add closing brackets until the indentation has
            }                 #reached the same level
        }
	}
}
sub print_routine {
    my @values = @_;
    my $format = 0;
    for my $i (0 .. $#values){
        my $var = $values[$i];
        $var =~ s/\;//;
        if ($#values eq 0){ #if just print, print a new line
            print "print \"\\n\"\;\n"; 
        } elsif ($var =~ /"/){
            if(($var =~ /"/) && ($var =~ /\"/)){
                if ($format == 0){
                    $format = 1;
                } else {
                    $format = 0;
                }
            } elsif ($var =~ /\"/){

            } elsif($format == 0){
                $format = 1;
            } else {
                $format = 0;
            }
            print "$var ";
        } elsif ($var =~ /$math_ops/){
            print "$var ";
        } elsif ($var =~ /print/) {
            print "$var ";  
        } elsif ($format == 1){
            print "$var ";
        } else {
            print looks_like_number($var) ? '' : '$', "$var ";
        } #similar approach to as above, split the string when see print 
    }
    print ",\"\\n\"\;\n";
}
sub print_noNewLine{
    my @values = @_;
    my $format = 0;
    for my $i (0 .. $#values){
        my $var = $values[$i];
        $var =~ s/\;//;
        if ($#values eq 0){ #if just print, print a space
            print "print \" \"\;\n"; 
        } elsif ($var =~ /"/){
            if(($var =~ /"/) && ($var =~ /\"/)){
                if ($format == 0){
                    $format = 1;
                } else {
                    $format = 0;
                }
            } elsif ($var =~ /\"/){

            } elsif($format == 0){
                $format = 1;
            } else {
                $format = 0;
            }
            print "$var ";
        } elsif ($var =~ /$math_ops/){
            print "$var ";
        } elsif ($format == 1){
            print "$var ";
        } elsif ($var =~ /print/) {
            print "$var ";  
        } else {
            print looks_like_number($var) ? '' : '$', "$var ";
        } #similar approach to as above, split the string when see print 
    }
}
sub printf_routine {
    my $line = shift;
    $line =~ s/\s+$//; 
    $line =~ s/print/printf/;
    $line =~ s/\"\s+\%\s+/\" \,\( /;
    #print "$line\;"; print " print \"\\n\"\;";

    my @values = split(' ', $line);
    my $i = 0;
    my $format = 0; #variable to keep track of where " starts and ends.
                    
    while($i <= $#values){
        my $var = $values[$i];
        if ($var =~ /printf/){
            print "printf ";
        } elsif ($var =~ /"/){
            if(($var =~ /"/) && ($var =~ /\"/)){
                if ($format == 0){
                    $format = 1;
                } else {
                    $format = 0;
                }
            } elsif ($var =~ /\"/){

            } elsif($format == 0){
                $format = 1;
            } else {
                $format = 0;
            }
            print "$var ";
        } elsif ($var =~ /\,\(/){
            print "$var ";
        } elsif (($var =~ s/\(//) || ($var =~ s/\)//)){
            print "\$$var ";
        } elsif ($format == 1){
            print "$var ";
        } else {
            print "\$$var ";
        }
        $i++;
    }
    print "\)\; print \"\\n\"\;";
}

sub control_routine {
    my @values = @_;
    my $i = 0;
    while ($i <= $#values){
        my $var = $values[$i];
        if ($var =~ /$control_flows/){
            if ($var =~ /elif/){
                print "elsif \(";                
            } else {
                print "$var \(";
            }
        }
        elsif ($var =~ /$math_ops/) { #if the variable is [=+-*/]
            print "$var ";
        }
         else{
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
        } elsif ($var =~ s/range\((.*)\,//) {
            print looks_like_number($1) ? '' : '$', "\($1 .. ";
        } elsif ($var =~ /$math_ops/){
            print "$var ";
        } elsif ($var =~ s/\)\://){
            $var -= 1;
            print looks_like_number($var) ? '' : '$', "$var\)\{\n";
        } elsif ($var =~ /in/){
            print '';
        }
        else {
            print looks_like_number($var) ? '' : '$', "$var ";
        }
        $i++;
    }
}
sub else_routine{
    print "else \{\n";
}   
sub stdin_readLines_routine {
    my $line = shift;
    my @values = split(' ', $line);
    my $var = $values[0];
    $array_vars{$var} = "\@$var"; 
    print "\@$var = <STDIN>;\n" 
}
sub length_routine{
    my $line = shift;
    my @values = split(' ', $line);
    my $i = 0;
    while ($i <= $#values){
        my $var = $values[$i];
        if ($var =~ /len\((\w+)\)/) {
            my $var2 = $1;
            if (exists $array_vars{$var2}){
                print "scalar\(\@$var2\) ";
            } elsif(exists $hash_vars{$var2}){
                print "scalar\(\%$var2\) ";
            } else {
                print "length\(\$$var2\) ";
            }
        } elsif ($var =~ /$math_ops/){
            print "$var ";
        } else {
            print looks_like_number($var) ? '' : '$', "$var ";
        }
        $i++;
    }
    print "\;\n";
}
