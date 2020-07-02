########################################################################
# COMP1521 20T2 --- assignment 1: a cellular automaton renderer
#
# Written by Dan Nguyen (z5206032), July 2020.

# World Variables
MIN_WORLD_SIZE  =    1
MAX_WORLD_SIZE  =  128
MIN_GENERATIONS = -256
MAX_GENERATIONS =  256
MIN_RULE        =	 0
MAX_RULE        =  255

# Cell Variables
MAX_CELLS_BYTES = (MAX_GENERATIONS + 1) * MAX_WORLD_SIZE
ALIVE_CHAR  = '#'
DEAD_CHAR   = '.'
ALIVE_BIT   = 1
DEAD_BIT    = 0


.data
    cells:                  .space  MAX_CELLS_BYTES
    prompt_world_size:      .asciiz "Enter world size: "
    error_world_size:       .asciiz "Invalid world size\n"
    prompt_rule:            .asciiz "Enter rule: "
    error_rule:             .asciiz "Invalid rule\n"
    prompt_n_generations:   .asciiz "Enter how many generations: "
    error_n_generations:    .asciiz "Invalid number of generations\n"

.text
    #
    # REPLACE THIS COMMENT WITH A LIST OF THE REGISTERS USED IN
    # `main', AND THE PURPOSES THEY ARE ARE USED FOR
    # 
    # $t0 = loop iteration variable, i
    #
    # YOU SHOULD ALSO NOTE WHICH REGISTERS DO NOT HAVE THEIR
    # ORIGINAL VALUE WHEN `run_generation' FINISHES
    #

main:
    li      $v0, 1                          # printf("Enter world size: ");
    la      $a0, prompt_world_size
    syscall	


    # replace the syscall below with
    #
    # li    $v0, 0
    # jr    $ra
    #
    # if your code for `main' preserves $ra by saving it on the
    # stack, and restoring it after calling `print_world' and
    # `run_generation'.  [ there are style marks for this ] 
    # li    $v0, 10
    # syscall   
    #
    # Given `world_size', `which_generation', and `rule', calculate
    # a new generation according to `rule' and store it in `cells'.
    #   
    #
    # REPLACE THIS COMMENT WITH A LIST OF THE REGISTERS USED IN
    # `run_generation', AND THE PURPOSES THEY ARE ARE USED FOR
    #
    # YOU SHOULD ALSO NOTE WHICH REGISTERS DO NOT HAVE THEIR
    # ORIGINAL VALUE WHEN `run_generation' FINISHES
    #   
run_generation: 
    #
    # REPLACE THIS COMMENT WITH YOUR CODE FOR `run_generation'.
    #
    jr      $ra
    #
    # Given `world_size', and `which_generation', print out the
    # specified generation.

# LIST OF USED REGISTERS
# 
# $t0 = row iteration, i
# $t1 = col iteration, j
# $t2 = starting address of cells array, start
# $t3 = current address of cells array, start + (i * width + j)
print_generation:

    bgt     GENERATIONS, 0, print_positive  # if (GENERATIONS > 0) goto print_positive;
    b       print_negative                  # goto print_negative;

print_negative:
    li      $t0, GENERATIONS                # i = GENERATIONS;
    la      $t2, cells                      # start = cells;

NL1:
    blt     $t0, 0, print_end               # if (i < 0) goto print_end;
    li      $t1, 0                          # j = 0;

NE1:
    li      $a0, '\n'                       # printf("\n");
    li      $v0, 11
    syscall

    subi    $t0, $t0, 1                     # i--;
    b       NL1                             # goto NL1;

print_positive:
    li      $t0, 0                          # i = 0;
    la      $t2, cells                      # start = cells;

PL1:
    bgt     $t0, GENERATIONS, print_end     # if (i > height) goto print_end;
    li      $t1, 0                          # j = 0;

PL2:
    bgt     $t1, WORLD, PE1                 # if (j > width) goto PE1;

    mul     $t3, $t0, width                 # $t3 = i * width;
    add     $t3, $t3, $t1                   # $t3 = i * width + j;
    mul     $t3, $t3, 4                     # $t3 = #t3 * sizeof(byte);
    
    add     $t3, $t3, $t2                   # curr = start + (i * width + j) * sizeof(byte);    
    li      $a0, ALIVE_CHAR                 # a0 = '#';
    beq     ($t3), ALIVE_BIT, print_char    # if (curr == ALIVE) goto print_char;
    li      $a0, DEAD_CHAR                  # a0 = '.';

print_char:
    li      $v0, 1                          # printf("%d", curr);
    syscall

    addi    $t1, $t1, 1                     # j++;
    b       PL2                             # goto PL2;

PE1:
    # li      $a0, '\n'                     # printf("\n");
    # li      $v0, 11
    # syscall

    addi    $t0, $t0, 1                     # i++;
    b       PL1                             # goto PL1;

print_end:
    jr      $ra                             # return;
