.data
T0: .space 4                           # the pointers to your lookup tables
T1: .space 4                           
T2: .space 4                           
T3: .space 4                           
fin: .asciiz "/Users/morhun/Downloads/CS401_Project/tables.dat"      # put the fullpath name of the file AES.dat here
t: .word 0x0, 0x0, 0x0, 0x0
s: .word 0xd82c07cd, 0xc2094cbd, 0x6baa9441, 0x42485e3f
rkey: .word 0x82e2e670, 0x67a9c37d, 0xc8a7063b, 0x4da5e71f
buffer: .space 5000                    # temporary buffer to read from file

.text
main:
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
  
  jal roundOperation

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

roundOperation:
    li $t2, 0 # counter
    la $t1, t # address of t
    
    iterateRound:
        beq $t2, 4, endRound # if counter == 16 then endRound
        la $t0, s # address of s
        add $t4, $t2, $zero # local counter
        li $t8, 4
        li $s7, 0 # result
        
    # T3[s[n]>>24]
        div $t4, $t8
        mfhi $t5 # modulo index on s
        sll $t5, $t5, 2 # multiply by 4 to get the word address
        add $t5, $t5, $t0 # add the offset to the address of s
        lw $t3, 0($t5) # s[n]

        srl $t3, $t3, 24 # s[0]>>24

        la $t9, T3         # address of T3
        lw $t9, 0($t9)     # load starting address of T3
        add $a0, $t9, $zero

        sll $t3, $t3, 2 # multiply by 4 to get the word address
        add $t9, $t9, $t3 # add the offset to the address of T3
        lw $s3, 0($t9)     # $s3 = T3[s[n]>>24]


    # T1[(s[n+1]>>16)&0xff]
        addi $t4, $t4, 1
        div $t4, $t8
        mfhi $t5
        sll $t5, $t5, 2 # multiply by 4 to get the word address
        add $t5, $t5, $t0 # add the offset to the address of s


        lw $t3, 0($t5) # s[n+1]

        srl $t3, $t3, 16 # s[n+1]>>16
        andi $t3, $t3, 0xff # (s[n+1]>>16)&0xff

        la $t9, T1         # address of T1
        lw $t9, 0($t9)     # load starting address of T1
        sll $t3, $t3, 2 # multiply by 4 to get the word address
        add $t9, $t9, $t3 # add the offset to the address of T1
        lw $s4, 0($t9)     # $s4 = T1[(s[n+1]>>16)&0xff]
       

    # T2[(s[n+2]>>8)&0xff]
        addi $t4, $t4, 1
        div $t4, $t8
        mfhi $t5
        sll $t5, $t5, 2 # multiply by 4 to get the word address
        add $t5, $t5, $t0 # add the offset to the address of s
        lw $t3, 0($t5) # s[n+2]

        srl $t3, $t3, 8 # s[n+2]>>8
        andi $t3, $t3, 0xff # (s[n+2]>>8)&0xff

        la $t9, T2        # address of T2
        lw $t9, 0($t9)     # load starting address of T2
        sll $t3, $t3, 2 # multiply by 4 to get the word address
        add $t9, $t9, $t3 # add the offset to the address of T2
        lw $s5, 0($t9)     # $s5 = T2[(s[n+2]>>8)&0xff]

    # T0[s[n+3]&0xff]
        addi $t4, $t4, 1
        div $t4, $t8
        mfhi $t5
        
        sll $t5, $t5, 2 # multiply by 4 to get the word address
        add $t5, $t5, $t0 # add the offset to the address of s
        lw $t3, 0($t5) # s[n+3]
        
        

        andi $t3, $t3, 0xff # (s[n+3])&0xff

        la $t9, T0        # address of T0
        lw $t9, 0($t9)     # load starting address of T0
        sll $t3, $t3, 2 # multiply by 4 to get the word address
        add $t9, $t9, $t3 # add the offset to the address of T0
        lw $s6, 0($t9)     # $s5 = T0[s[n+3]&0xff]

	
        # rkey[n]
        la $t9, rkey        # address of rkey
        add $t4, $t2, $zero # local counter
        sll $t4, $t4, 2 # multiply by 4 to get the word address
        add $t9, $t9, $t4 # add the offset to the address of rkey
        lw $t7, 0($t9) # rkey[n]


    # result
        xor $s7, $s3, $s4
        xor $s7, $s7, $s5
        xor $s7, $s7, $s6
        xor $s7, $s7, $t7

	      sw $s7, 0($t1)
        addi $t1, $t1, 4
        addi $t2, $t2, 1
        j iterateRound
    endRound:
        jr $ra

Exit:
li $v0,10
syscall             # exits the program