.data  
T0: .space 4                           # the pointers to your lookup tables
T1: .space 4                           
T2: .space 4                           
T3: .space 4                           
fin: .asciiz "/Users/morhun/Downloads/CS401_Project/tables.dat"      # put the fullpath name of the file AES.dat here
buffer: .space 5000                    # temporary buffer to read from file

.text
#open a file for writing
li   $v0, 13       # system call for open file
la   $a0, fin      # file name
li   $a1, 0        # Open for reading
li   $a2, 0
syscall            # open a file (file descriptor returned in $v0)
move $s6, $v0      # save the file descriptor 

#read from file
li   $v0, 14       # system call for read from file
move $a0, $s6      # file descriptor 
la   $a1, buffer   # address of buffer to which to read
li   $a2, 12288    # hardcoded buffer length
syscall            # read from file

move $s0, $v0	   # the number of characters read from the file
la   $s1, buffer   # address of buffer that keeps the characters


# your code goes here
  # Allocate memory for lookup tables
  la $t0, T0         # address of T0
  li $v0, 9
  li $a0, 1024
  syscall
  sw $v0, 0($t0)

  la $t0, T1         # address of T1
  li $v0, 9
  li $a0, 1024
  syscall
  sw $v0, 0($t0)

  la $t0, T2         # address of T2
  li $v0, 9
  li $a0, 1024
  syscall
  sw $v0, 0($t0)

  la $t0, T3         # address of T3
  li $v0, 9
  li $a0, 1024
  syscall
  sw $v0, 0($t0)

  # Convert hexadecimal table entries to binary 
  la $t0, T0         # address of T0
  lw $a0, 0($t0)     # load starting address of T0
  li $a1, 256        # number of entries
  jal convert_table

  la $t0, T1         # address of T1
  lw $a0, 0($t0)     # load starting address of T1
  li $a1, 256        # number of entries
  jal convert_table

  la $t0, T2         # address of T2
  lw $a0, 0($t0)     # load starting address of T2
  li $a1, 256        # number of entries
  jal convert_table

  la $t0, T3         # address of T3
  lw $a0, 0($t0)     # load starting address of T3
  li $a1, 256        # number of entries
  jal convert_table
  j Exit
  
convert_table:
# Allocate stack memmory for ra
addi $sp, $sp, -4
sw $ra, 0($sp)

move $s2, $a0 #start adress of our table
move $s3, $a1 #number of entries

TableLoop:
lb $t1, 0($s1)     	# load current character, get a byte from hex
beq $t1, 13, SwitchTable #if current char is \n, switch tables

# First two char will always be 0x, skip them
addi $s1, $s1, 2	

# Convert next 8 hex digit to binary and save them into our table
storeHex:
  li $v1, 0

  lb $t1, 0($s1) # get a byte from the buffer
  jal checkValue
  sll $t2, $t1, 28
  or $v1, $v1, $t2

  lb $t1, 1($s1) # get a byte from the buffer
  jal checkValue
  sll $t2, $t1, 24
  or $v1, $v1, $t2

  lb $t1, 2($s1) # get a byte from the buffer
  jal checkValue
  sll $t2, $t1, 20
  or $v1, $v1, $t2

  lb $t1, 3($s1) # get a byte from the buffer
  jal checkValue
  sll $t2, $t1, 16
  or $v1, $v1, $t2

  lb $t1, 4($s1) # get a byte from the buffer
  jal checkValue
  sll $t2, $t1, 12
  or $v1, $v1, $t2

  lb $t1, 5($s1) # get a byte from the buffer
  jal checkValue
  sll $t2, $t1, 8
  or $v1, $v1, $t2

  lb $t1, 6($s1) # get a byte from the buffer
  jal checkValue
  sll $t2, $t1, 4
  or $v1, $v1, $t2

  lb $t1, 7($s1) # get a byte from the buffer
  jal checkValue
  or $v1, $v1, $t1

  sw $v1, 0($s2) # store the value in the memory

  j continue

  checkValue:
    li $t2, 97 # a
    beq $t1, $t2, setA
    li $t2, 98 # b
    beq $t1, $t2, setB
    li $t2, 99 # c
    beq $t1, $t2, setC
    li $t2, 100 # d
    beq $t1, $t2, setD
    li $t2, 101 # e
    beq $t1, $t2, setE
    li $t2, 102 # f
    beq $t1, $t2, setF
    j setNumeric

    setA:
      li $t1, 10
      jr $ra
    setB:
      li $t1, 11
      jr $ra
    setC:
      li $t1, 12
      jr $ra
    setD:
      li $t1, 13
      jr $ra
    setE:
      li $t1, 14
      jr $ra
    setF:
      li $t1, 15
      jr $ra
    setNumeric:
      sub $t1, $t1, 48
      jr $ra

continue:
addi $s2, $s2, 4 # increase our talbe pointer by a word size since we added an 32 bit integer

# Check next char after last 8 bit of Hex if it is , skip 2 char else it will be \n and handled at the beginning of loop
addi $s1, $s1, 8
lb $t1, 0($s1)
beq $t1, 44, SkipCommaSpace # we arrived to comman and space, skip them

j TableLoop


SkipCommaSpace:
addi $s1, $s1, 2		# skip the next two chars of our data (, )
j TableLoop

SwitchTable:
# Release stack memmory
addi $s1, $s1, 2
lw $ra, 0($sp)
addi $sp, $sp, 4
jr $ra

Exit:
li $v0,10
syscall             # exits the program