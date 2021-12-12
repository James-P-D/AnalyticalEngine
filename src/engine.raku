#---------------------------------#
# is_integer()                    #
#---------------------------------#

sub is_integer($s) {
    try {
        my Int() $tempInt = Int($s);
    }
 
    if $! { 
        return 0;
    }
    return 1;
}

#---------------------------------#
# enter_integer()                 #
#---------------------------------#

sub enter_integer($msg) {
    until defined try my Int() $int-input = prompt $msg {
        say "Invalid input. Expected an integer.";
    }

    return $int-input;
}

#---------------------------------#
# MAIN()                          #
#---------------------------------#

sub MAIN($filename) {
    # Open the input file
    my $file_handle = open $filename, :r; 
    my $line_number = 0;
    my @instructions;
    
    # Read each line
    for $file_handle.IO.lines -> $line {
        my $comment_indexes = $line.indices("#");
        if ($comment_indexes.elems > 0) {
            # If we have a comment, strip it..
            @instructions[$line_number] = substr($line, 0 .. $comment_indexes[0]-1).trim();
        } else {
            # ..otherwise, add the whole string
            @instructions[$line_number] = $line.trim();
        }
        $line_number++;
    }
    
    # Create the memory dictionary
    my %memory;
    my $maths_operator = "";
    my $ingress1 = 0;
    my $ingress2 = 0;
    my $ingress_read = 0;
    my $egress = 0;
    $line_number = 0;
    
    while ($line_number < elems(@instructions)) {
        my $instruction = @instructions[$line_number];
        say $instruction;
        
        if ($instruction.chars == 0) {
            printf("Warning: Empty instruction at line %d\n", ($line_number + 1));
            $line_number++;
            next;
        }
        
        if ($instruction.starts-with("N")) {
            my $tokens = split(" ", substr($instruction, 1 .. *));
            if ($tokens.elems != 2) {
                printf("ERROR: '%s' at line %d\n", $instruction, ($line_number + 1));
                printf("ERROR: Expected 2 parameters for command 'N' but found %d\n", $tokens.elems);
                return;            
            }
            
            if (!is_integer($tokens[0])) {
                printf("ERROR: '%s' at line %d\n", $instruction, ($line_number + 1));
                printf("ERROR: Expected integer for parameter 1 for command 'N' but found %s\n", $tokens[0]);
                return;
            }
            
            if ($tokens[1] eq "INPUT") {
                my $int_input = enter_integer("Enter input for " ~ "N" ~ $tokens[0] ~ ": ");
                %memory{ $tokens[0] } = $int_input;                
            } elsif ($tokens[1] eq "OUTPUT") {

                if (%memory{$tokens[0]}:!exists) {
                    printf("ERROR: '%s' at line %d\n", $instruction, ($line_number + 1));
                    printf("ERROR: Attempt to access uninitialised memory\n");
                    return;
                }
                say %memory{$tokens[0]};
            } elsif (!is_integer($tokens[1])) {
                printf("ERROR: '%s' at line %d\n", $instruction, ($line_number + 1));
                printf("ERROR: Expected integer or 'INPUT' for parameter 2 for command 'N' but found %s\n", $tokens[1]);
                return;
            } else {
                %memory{$tokens[0]} = $tokens[1];
            }
            
            $line_number++;
        } elsif ($instruction.starts-with("L")) {
            my $tokens = split(" ", substr($instruction, 1 .. *));
            if ($tokens.elems != 1) {
                printf("ERROR: '%s' at line %d\n", $instruction, ($line_number + 1));
                printf("ERROR: Expected 1 parameters for command 'L' but found %d\n", $tokens.elems);
                return;            
            }
            
            if (!is_integer($tokens[0])) {
                printf("ERROR: '%s' at line %d\n", $instruction, ($line_number + 1));
                printf("ERROR: Expected integer for parameter 1 for command 'L' but found %s\n", $tokens[0]);
                return;
            }

            if ($maths_operator eq "") {
                printf("ERROR: '%s' at line %d\n", $instruction, ($line_number + 1));
                printf("ERROR: Attempt to load without a mathematical operation set\n");
                return;
            }
            
            if (%memory{$tokens[0]}:!exists) {
                printf("ERROR: '%s' at line %d\n", $instruction, ($line_number + 1));
                printf("ERROR: Attempt to access uninitialised memory\n");
                return;
            }

            if ($ingress_read == 0) {
                $ingress1 = %memory{$tokens[0]};
                $ingress_read = 1;
            } elsif ($ingress_read == 1) {
                $ingress2 = %memory{$tokens[0]};
                $ingress_read = 2;
                
                if ($maths_operator eq "+") {
                    $egress = $ingress1 + $ingress2;
                } elsif ($maths_operator eq "-") {
                    $egress = $ingress1 - $ingress2;
                } elsif ($maths_operator eq "*") {
                    $egress = $ingress1 * $ingress2;
                } elsif ($maths_operator eq "/") {
                    $egress = $ingress1 / $ingress2;
                } elsif ($maths_operator eq "%") {
                    $egress = $ingress1 % $ingress2;
                } else {
                    printf("ERROR: Unknown maths operator '%s'\n", $maths_operator);
                    return;
                }
                
                $ingress_read = 0;
            }

            $line_number++;
        } elsif ($instruction.starts-with("S")) {
            my $tokens = split(" ", substr($instruction, 1 .. *));
            if ($tokens.elems != 1) {
                printf("ERROR: '%s' at line %d\n", $instruction, ($line_number + 1));
                printf("ERROR: Expected 1 parameters for command 'S' but found %d\n", $tokens.elems);
                return;            
            }
            
            if (!is_integer($tokens[0])) {
                printf("ERROR: '%s' at line %d\n", $instruction, ($line_number + 1));
                printf("ERROR: Expected integer for parameter 1 for command 'L' but found %s\n", $tokens[0]);
                return;
            }
            
            %memory{$tokens[0]} = $egress;

            $line_number++;
        } elsif ($instruction.starts-with("CB?")) {
            my $tokens = split(" ", substr($instruction, 3 .. *));
            if ($tokens.elems != 1) {
                printf("ERROR: '%s' at line %d\n", $instruction, ($line_number + 1));
                printf("ERROR: Expected 1 parameters for command 'CB?' but found %d\n", $tokens.elems);
                return;            
            }
            
            if (!is_integer($tokens[0])) {
                printf("ERROR: '%s' at line %d\n", $instruction, ($line_number + 1));
                printf("ERROR: Expected integer for parameter 1 for command 'CB?' but found %s\n", $tokens[0]);
                return;
            }
            
            # Check condition then Check if $tokens >=1 and < elems(@instructions)

            if ($egress == 0) {
                $line_number++;
            } else {
                $line_number -= $tokens[0];
            }
        } elsif (($instruction eq "+") ||
                 ($instruction eq "-") ||
                 ($instruction eq "*") ||
                 ($instruction eq "/") ||
                 ($instruction eq "%")) {
            $maths_operator = $instruction;
            $line_number++;
        } else {
            printf("ERROR: Unknown instuction '%s' at line %d\n", $instruction, ($line_number + 1));
            return;
        }
        
        #sleep(0.100);
    }
}