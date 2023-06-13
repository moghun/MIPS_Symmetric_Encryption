.data
T0: .space 4                           # the pointers to your lookup tables
T1: .space 4                           
T2: .space 4                           
T3: .space 4                           
fin: .asciiz "/Users/morhun/Downloads/CS401_Project/tables.dat"    # put the fullpath name of the file AES.dat here
t: .word 0x0, 0x0, 0x0, 0x0
s: .word 0xd82c07cd, 0xc2094cbd, 0x6baa9441, 0x42485e3f
rkey: .word 0x6920e299, 0xa5202a6d, 0x656e6368, 0x69746f2a #initialize as secretkey
rcon: .word 0x80, 0x40, 0x20, 0x10, 0x08, 0x04, 0x02, 0x01
buffer: .space 5000                    # temporary buffer to read from file

.text
keySchedule:
    # Save pc for return
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    # Execute the round operation eight times using 8 different round keys
    # Create round key 1
    la $a0, rkey
    la $a1, rcon
    jal updaterkey
    # Apply round operation on s with round key1
    la $a0, rkey
    la $a1, s
    jal roundOperation
    
    # Create round key 2
    la $a0, rkey
    la $t0, rcon
    addi $t0, $t0, 4 # Get next rcon value to $t0
    move $a1, $t0
    jal updaterkey
    # Apply round operation on (resulting state from last round operation) t with round key2
    la $a0, rkey
    la $a1, t
    jal roundOperation

    # Create round key 3
    la $a0, rkey
    la $t0, rcon
    addi $t0, $t0, 8 # Get next rcon value to $t0
    move $a1, $t0
    jal updaterkey
    # Apply round operation on (resulting state from last round operation) t with round key3
    la $a0, rkey
    la $a1, t
    jal roundOperation
    
    # Create round key 4
    la $a0, rkey
    la $t0, rcon
    addi $t0, $t0, 12 # Get next rcon value to $t0
    move $a1, $t0
    jal updaterkey
    # Apply round operation on (resulting state from last round operation) t with round key4
    la $a0, rkey
    la $a1, t
    jal roundOperation
    
    # Create round key 5
    la $a0, rkey
    la $t0, rcon
    addi $t0, $t0, 16 # Get next rcon value to $t0
    move $a1, $t0
    jal updaterkey
    # Apply round operation on (resulting state from last round operation) t with round key5
    la $a0, rkey
    la $a1, t
    jal roundOperation
    
    # Create round key 6
    la $a0, rkey
    la $t0, rcon
    addi $t0, $t0, 20 # Get next rcon value to $t0
    move $a1, $t0
    jal updaterkey
    # Apply round operation on (resulting state from last round operation) t with round key6
    la $a0, rkey
    la $a1, t
    jal roundOperation
    
    # Create round key 7
    la $a0, rkey
    la $t0, rcon
    addi $t0, $t0, 24 # Get next rcon value to $t0
    move $a1, $t0
    jal updaterkey
    # Apply round operation on (resulting state from last round operation) t with round key7
    la $a0, rkey
    la $a1, t
    jal roundOperation
    
    # Create round key 8
    la $a0, rkey
    la $t0, rcon
    addi $t0, $t0, 28 # Get next rcon value to $t0
    move $a1, $t0
    jal updaterkey
    # Apply round operation on (resulting state from last round operation) t with round key8
    la $a0, rkey
    la $a1, t
    jal roundOperation

    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra


Exit:
li $v0,10
syscall             # exits the program