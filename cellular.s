########################################################################
# COMP1521 20T2 --- assignment 1: a cellular automaton renderer
#
# Written by Dan Nguyen (z5206032), July 2020.

# World Definitions
MIN_WORLD_SIZE  =    1
MAX_WORLD_SIZE  =  128
MIN_GENERATIONS = -256
MAX_GENERATIONS =  256
MIN_RULE        =	 0
MAX_RULE        =  255

# Cell Definitions
MAX_CELLS_BYTES = (MAX_GENERATIONS + 1) * MAX_WORLD_SIZE
ALIVE_CHAR  = '#'
DEAD_CHAR   = '.'
ALIVE_BIT   = 1
DEAD_BIT    = 0

# Other definitions
SIZEOF_BYTE = 4

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
# $s0 = world size, width
# $s1 = number of generations, height
# $s2 = rule
#
# YOU SHOULD ALSO NOTE WHICH REGISTERS DO NOT HAVE THEIR
# ORIGINAL VALUE WHEN `run_generation' FINISHES
#
main:
    li      $v0, 4                          # printf("Enter world size: ");
    la      $a0, prompt_world_size
    syscall

    li      $v0, 5                          # scanf("%d", width);
    syscall
    move    $s0, $v0

    li      $v0, 4                          # printf("Enter rule: ");
    la      $a0, prompt_rule
    syscall

    li      $v0, 5                          # scanf("%d", rule);
    syscall
    move    $s2, $v0

    li      $v0, 4                          # printf("Enter how many generations: ");
    la      $a0, prompt_n_generations
    syscall

    li      $v0, 5                          # scanf("%d", height);
    syscall
    move    $s1, $v0

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

# PRINT_GENERATION
# 
# $s0 = world size, width
# $s1 = number of generations, height
# 
# $t0 = row iteration, i
# $t1 = col iteration, j
# $t2 = starting address of cells array, start
# $t3 = current address of cells array, start + (i * width + j)
# $t4 = abs(i)
# $t5 = height + 1 for height < 0
# $t6 = negative flag, 1 if True, 0 if False
print_generation:
    slti    $t0, $s1, 0                     # i = height < 0 ? 1 : 0;
    move    $t6, $t0                        # flag = i; // flag == 1 || 0
    addi    $t5, $s1, 1                     # height = height + 1; // height < 0
    mul     $t0, $t0, $t5                   # i *= height; // i == 0 || height
    la      $t2, cells                      # start = cells;

PL1:
    abs     $t4, $t0                        # $t4 = abs(i);
    beq     $t6, $zero, print_cond          # if (flag == False) goto print_cond;

    bgt     $t0, $zero, print_end           # if (abs(i) > 0) goto print_end;
    b		print_skip_cond			        # goto print_skip_cond;

print_cond:
    bge     $t0, $s1, print_end             # if (i >= height) goto print_end;

print_skip_cond:
    move    $a0, $t4                        # printf("i");
    li      $v0, 1
    syscall

    li      $a0, '\t'                       # printf("\t");
    li      $v0, 11
    syscall

    li      $t1, 0                          # j = 0;

PL2:
    bge     $t1, $s0, PE1                   # if (j >= width) goto PE1;

    mul     $t3, $t4, $s1                   # $t3 = i * width;
    add     $t3, $t3, $t1                   # $t3 = i * width + j;
    mul     $t3, $t3, SIZEOF_BYTE           # $t3 = #t3 * sizeof(byte);
    
    add     $t3, $t3, $t2                   # curr = start + (i * width + j) * sizeof(byte);    
    li      $a0, ALIVE_CHAR                 # a0 = '#';
    
    lw      $t3, ($t3)
    beq     $t3, ALIVE_BIT, print_char      # if (curr == ALIVE) goto print_char;
    li      $a0, DEAD_CHAR                  # a0 = '.';

print_char:
    li      $v0, 11                         # printf("%d", curr);
    syscall

    addi    $t1, $t1, 1                     # j++;
    b       PL2                             # goto PL2;

PE1:
    li      $a0, '\n'                       # printf("\n");
    li      $v0, 11
    syscall

    addi    $t0, $t0, 1                     # i++;
    b       PL1                             # goto PL1;

print_end:
    jr      $ra                             # return;
