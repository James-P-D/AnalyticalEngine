sub is_integer($s) {
    $s.Int;

    CATCH {
        default {
            return 0;
        }
    }
    
    return 1;
}

sub MAIN($filename) {    
    my $file_handle = open $filename, :r;
 
    my $line_number = 0;
    my @instructions;
    
    for $file_handle.IO.lines -> $line {        
        my $comment_indexes = $line.indices("#");
        if ($comment_indexes.elems > 0) {
            @instructions[$line_number] = substr($line, 0 .. $comment_indexes[0]-1).trim();
        } else {
            @instructions[$line_number] = $line.trim();
        }
        $line_number++;
    }
    
    my %memory;
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
                printf("Enter input for N%d:", $tokens[0]);
                my $int_input = get;
                while (!is_integer($int_input)) {
                    printf("Enter input for N%d:", $tokens[0]);
                    $int_input = get;
                }
                %memory{ $tokens[0] } = $int_input;
                
            } elsif (!is_integer($tokens[0])) {
                printf("ERROR: '%s' at line %d\n", $instruction, ($line_number + 1));
                printf("ERROR: Expected integer or 'INPUT' for parameter 2 for command 'N' but found %s\n", $tokens[1]);
                return;
            } else {
                %memory{$tokens[0]} = $tokens[1];
            }
            
            say %memory{$tokens[0]};
        } elsif ($instruction.starts-with("L")) {
            say "Load?!";
        } elsif ($instruction.starts-with("S")) {
            say "Load?!";
        } elsif ($instruction.starts-with("CB?")) {
            say "Conditional branch?!";
        } elsif ($instruction.starts-with("+") ||
                 $instruction.starts-with("-") ||
                 $instruction.starts-with("*") ||
                 $instruction.starts-with("/") ||
                 $instruction.starts-with("%")) {
            say "Maths";
        } else {
            printf("ERROR: Unknown instuction '%s' at line %d\n", $instruction, ($line_number + 1));
            return;
        }
        
        $line_number++;
        say "--------------------------";
    }
}