########################################################################
# COMP1521 20T2 --- assignment 1: a cellular automaton renderer
#
# Written by Dan Nguyen (z5206032), July 2020.

# World Definitions
MIN_WORLD_SIZE  =    1
MAX_WORLD_SIZE  =  128
MIN_GENERATIONS = -256
MAX_GENERATIONS =  256
MIN_RULE        =    0
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
# main:
# 
# $s0, $a0 = world size, width
# $s1, $a1 = number of generations, height
# $s2, $a2 = rule, cells
main:
    li      $v0, 4                          # printf("Enter world size: ");
    la      $a0, prompt_world_size
    syscall

    li      $v0, 5                          # scanf("%d", width);
    syscall
    move    $s0, $v0

    la      $a0, error_world_size
    blt     $s0, MIN_WORLD_SIZE, error_end  # if (width < MIN_WORLD_SIZE) goto error_end;
    bgt     $s0, MAX_WORLD_SIZE, error_end  # if (width > MAX_WORLD_SIZE) goto error_end;

    li      $v0, 4                          # printf("Enter rule: ");
    la      $a0, prompt_rule
    syscall

    li      $v0, 5                          # scanf("%d", rule);
    syscall
    move    $s2, $v0

    la      $a0, error_rule
    blt     $s2, MIN_RULE, error_end        # if (rule < MIN_RULE) goto error_end;
    bgt     $s2, MAX_RULE, error_end        # if (rule > MAX_RULE) goto error_end;

    li      $v0, 4                          # printf("Enter how many generations: ");
    la      $a0, prompt_n_generations
    syscall

    li      $v0, 5                          # scanf("%d", height);
    syscall
    move    $s1, $v0

    la      $a0, error_n_generations
    blt     $s2, MIN_GENERATIONS, error_end # if (height < MIN_GENERATIONS) goto error_end;
    bgt     $s2, MAX_GENERATIONS, error_end # if (height > MAX_GENERATIONS) goto error_end;

    li      $a0, '\n'                       # printf("\n");
    li      $v0, 11
    syscall

    move    $a0, $s0                        # width = width;
    move    $a1, $s1                        # height = height;
    move    $a2, $s2                        # rule = rule;

    addi    $sp, $sp, -4
    sw      $ra, ($sp)
    jal     run_generation                  # int *cells = run_generation(width, height, rule);
    lw      $ra, ($sp)
    addi    $sp, $sp, 4

    move    $a0, $s0                        # width = width;
    # move    $a1, $s1                        # height = height;
    move    $a2, $v0                        # cells = cells;

    addi    $sp, $sp, -4
    sw      $ra, ($sp)
    jal     print_generation                # void print_generation(width, height, cells);
    lw      $ra, ($sp)
    addi    $sp, $sp, 4

    jr      $ra                             # return;

error_end:
    li      $v0, 4                          # printf("$s", error);
    syscall

    jr      $ra                             # return;

# run_generation
# 
# $s0 = width
# $s1 = height
# $s2 = rule
# 
# $t0 = row iteration, i
# $t1 = col iteration, j
# $t2 = starting address of cells array, start
# $t3 = left, start + (i * width + j - 1)
# $t4 = centre, start + (i * width + j)
# $t5 = right, start + (i * width + j + 1)
# $t6 = state, left << 2 | centre << 1 | right << 0
# $t7 = bit, 1 << state
# $t8 = set, rule & bit
# $t9 = placeholder for 1
run_generation:
    move    $s0, $a0                        # width = width;
    move    $s1, $a1                        # height = height;
    move    $s2, $a2                        # rule = rule;

    abs     $s1, $s1                        # height = abs(height);

    li      $t0, 1                          # i = 1;
    la      $t2, cells                      # start = cells;

    divu    $t4, $s0, 2                     # $t4 = world_size / 2;
    mul     $t4, $t4, SIZEOF_BYTE           # $t4 = $t4 * sizeof(byte);
    add     $t4, $t4, $t2                   # centre = start + (world_size / 2) * sizeof(byte);
    sw      $t0, ($t4)                      # centre = 1;

RL1:
    bgt     $t0, $s1, run_end               # if (i > height) goto run_end;

    li      $t1, 0                          # j = 0;

RL2:
    bge     $t1, $s0, RE1                   # if (j >= width) goto RE1;

    li      $t3, 0                          # left = 0;
    li      $t4, 0                          # centre = 0;
    li      $t5, 0                          # right = 0;

    addi    $t0, $t0, -1                    # i - 1;
    addi    $t1, $t1, -1                    # j - 1;
    blt     $t1, 0, run_centre              # if ((j - 1) < 0) goto run_centre;
    beq     $t1, 0xffffff, run_centre       # if ((j - 1) == 0xffffff) goto run_centre;

    mul     $t3, $t0, $s0                   # $t3 = (i - 1) * width;
    add     $t3, $t3, $t1                   # $t3 = (i - 1) * width + (j - 1);
    mul     $t3, $t3, SIZEOF_BYTE           # $t3 = $t3 * sizeof(byte);
    add     $t3, $t3, $t2                   # left = start + ((i - 1) * width + (j - 1)) * sizeof(byte);
    lw      $t3, ($t3)

run_centre:
    addi    $t1, $t1, 1                     # j;
    mul     $t4, $t0, $s0                   # $t4 = (i - 1) * width;
    add     $t4, $t4, $t1                   # $t4 = (i - 1) * width + j;
    mul     $t4, $t4, SIZEOF_BYTE           # $t4 = $t4 * sizeof(byte);
    add     $t4, $t4, $t2                   # centre = start + ((i - 1) * width + j) * sizeof(byte);
    lw      $t4, ($t4)

    addi    $t1, $t1, 1                     # j + 1;
    # bge     $t1, 0, run_skip_right          # if ((j + 1) >= world_size) goto run_skip_right;

    mul     $t5, $t0, $s0                   # $t5 = (i - 1) * width;
    add     $t5, $t5, $t1                   # $t5 = (i - 1) * width + (j + 1);
    mul     $t5, $t5, SIZEOF_BYTE           # $t5 = $t5 * sizeof(byte);
    add     $t5, $t5, $t2                   # right = start + ((i - 1) * width + (j + 1)) * sizeof(byte);
    lw      $t5, ($t5)

 run_skip_right:
    sll     $t3, $t3, 2                     # left <<= 2;
    sll     $t4, $t4, 1                     # centre <<= 1;
    sll     $t5, $t5, 0                     # right <<= 0;

    or      $t6, $t3, $t4                   # state = left | centre;
    or      $t6, $t6, $t5                   # state |= right;
    li      $t9, 1                          # $t9 = 1;
    sllv    $t7, $t9, $t6                   # bit = $t9 << state;
    and     $t8, $s2, $t7                   # set = rule & bit;

    addi    $t0, $t0, 1                     # i;
    addi    $t1, $t1, -1                    # j;
    mul     $t4, $t0, $s0                   # $t4 = i * width;
    add     $t4, $t4, $t1                   # $t4 = i * width + j;
    mul     $t4, $t4, SIZEOF_BYTE           # $t4 = $t4 * sizeof(byte);
    add     $t4, $t4, $t2                   # centre = start + (i * width + j) * sizeof(byte);

    slti    $t8, $t8, 1                     # set = set < 1 ? 1 : 0;
    xori    $t8, $t8, 1                     # set ^= 1;
    sw      $t8, ($t4)                      # centre = set;

    addi    $t1, $t1, 1                     # j++;
    b       RL2                             # goto RL2;

RE1:
    addi    $t0, $t0, 1                     # i++;
    b       RL1                             # goto RL1;

run_end:
    move    $v0, $t2
    jr      $ra                             # return cells;

# print_generation
# 
# $s0 = width
# $s1 = height
# $s2 = starting address of cells array, start
# 
# $t0 = row iteration, i
# $t1 = col iteration, j
# $t2 = negative flag, 1 if True, 0 if False
# $t3 = current address of cells array, start + (i * width + j)
# $t4 = abs(i)
# $t5 = height + 1 for height < 0
print_generation:
    move    $s0, $a0                        # width = width;
    move    $s1, $a1                        # height = height;
    move    $s2, $a2                        # cells = cells;

    slti    $t0, $s1, 0                     # i = height < 0 ? 1 : 0;
    move    $t2, $t0                        # flag = i; // flag == 1 || 0
    mul     $t0, $t0, $s1                   # i *= height; // i == 0 || height

PL1:
    abs     $t4, $t0                        # $t4 = abs(i);
    beq     $t2, $zero, print_cond          # if (flag == False) goto print_cond;

    bgt     $t0, $zero, print_end           # if (abs(i) > 0) goto print_end;
    b       print_skip_cond                 # goto print_skip_cond;

print_cond:
    bgt     $t0, $s1, print_end             # if (i > height) goto print_end;

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

    mul     $t3, $t4, $s0                   # $t3 = i * width;
    add     $t3, $t3, $t1                   # $t3 = i * width + j;
    mul     $t3, $t3, SIZEOF_BYTE           # $t3 = $t3 * sizeof(byte);
    add     $t3, $t3, $s2                   # curr = start + (i * width + j) * sizeof(byte);
    lw      $t3, ($t3)

    li      $a0, ALIVE_CHAR                 # a0 = '#';
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
    jr      $ra                             # return void;
