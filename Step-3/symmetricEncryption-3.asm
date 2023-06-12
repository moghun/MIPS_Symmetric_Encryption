# Muhammed Orhun Gale - Ege Zorlutuna

.data
T0: .space 4                           # the pointers to your lookup tables
T1: .space 4                           
T2: .space 4                           
T3: .space 4                           

fin: .asciiz "/Users/morhun/Downloads/CS401_Project/tables.dat"    # put the fullpath name of the file AES.dat here

key: .word 0x2b7e1516, 0x28aed2a6, 0xabf71588, 0x09cf4f3c # 
rkey: .word 0x2b7e1516, 0x28aed2a6, 0xabf71588, 0x09cf4f3c # initialize as secretkey
rcon: .word 0x80, 0x40, 0x20, 0x10, 0x08, 0x04, 0x02, 0x01

s: .word 0x0, 0x0, 0x0, 0x0
t: .word 0x0, 0x0, 0x0, 0x0

message: .word 0x0, 0x0, 0x0, 0x0
ciphertext: .word 0x0, 0x0, 0x0, 0x0

inputBuffer:      .space 5000    # Input buffer to store user input
prompt:     .asciiz "Enter your message to be encrypted: "
inputArray:     .word 0:5000
newline: .asciiz "\n"

buffer: .space 5000                    # temporary buffer to read from file

.text

main:
# open a file for writing
li   $v0, 13       # system call for open file
la   $a0, fin      # file name
li   $a1, 0        # Open for reading
li   $a2, 0
syscall            # open a file (file descriptor returned in $v0)
move $s6, $v0      # save the file descriptor 

# read from file
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
  
  jal getMessageAndEncrypt
  
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
    # a0 --> address of rkey
    # a1 --> address of s
    # v0 --> return
    li $t2, 0 # counter
    la $t1, t # address of t
    
    iterateRound:
        beq $t2, 4, endRound # if counter == 16 then endRound
        add $t0, $a1, $zero # address of s
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
        add $t9, $a0, $zero        # address of rkey
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

updaterkey:
    # a0 --> address of rkey
    # a1 --> address of proper rcon value
    # v0 --> return
    lw $t1, 8($a0) # Load rkey[2] into $t1
    lw $t8, 0($a1) # Get proper rcon value

    # extracting a, b, c, d
    # a = (rkey[2] >> 24) & 0xFF
    srl $t2, $t1, 24  
    andi $t2, $t2, 0xFF
    
    # b = (rkey[2] >> 16) & 0xFF
    srl $t3, $t1, 16  
    andi $t3, $t3, 0xFF

    # c = (rkey[2] >> 8) & 0xFF
    srl $t4, $t1, 8   
    andi $t4, $t4, 0xFF

    # d = rkey[2] & 0xFF
    andi $t5, $t1, 0xFF 
    
    # Get adress of T2
    la $t7, T2
    lw $t7, 0($t7)
    
    # calculating e, f, g, h
    sll $t3, $t3, 2   	# converting byte index to word index
    add $t3, $t3, $t7	# adress of T2 + b, add the offset to the address of T2
    lw $t3, ($t3)  	# Load T2[b] into $t3
    andi $t3, $t3, 0xFF
    xor $t3, $t3, $t8   # e = (T2[b]&0xFF)^ rcon[i] in $t3
    
    sll $t4, $t4, 2
    add $t4, $t4, $t7	# adress of T2 + c,  add the offset to the address of T2
    lw $t4, ($t4)	# f = T2[c] in $t4
    andi $t4, $t4, 0xFF	# f = T2[c]&0xFF in $t4
    
    sll $t5, $t5, 2
    add $t5, $t5, $t7	# adress of T2 + d,  add the offset to the address of T2
    lw $t5, ($t5)	# g = T2[d]&0xFF in $t5
    andi $t5, $t5, 0xFF	# g = T2[d] in $t5
    
    sll $t2, $t2, 2
    add $t2, $t2, $t7	# adress of T2 + a,  add the offset to the address of T2
    lw $t2, ($t2)	# h = T2[a] in $t2
    andi $t2, $t2, 0xFF	# h = T2[a]&0xFF in $t2
    
    # calculating tmp
    sll $t3, $t3, 24	# sll 24 on e
    sll $t4, $t4, 16	# sll 16 on f
    sll $t5, $t5, 8	# sll 8 on g
    or $t3, $t3, $t4
    or $t3, $t3, $t5
    or $t3, $t3, $t2
    
    # update rkey
    lw $t0, 0($a0)	# Get rkey[0] on $t0
    xor $t0, $t0, $t3	# rkey[0] ^ tmp
    sw $t0, 0($a0)	# Save rkey[0}
    
    lw $t1, 4($a0)	# Get rkey[1] on $t1
    xor $t1, $t1, $t0	# rkey[1] = rkey[1] ^ rkey[0]
    sw $t1, 4($a0)	# Save rkey[1] 
    
    lw $t2, 8($a0)	# Get rkey[2] on $t2
    xor $t2, $t2, $t1	# rkey[2] = rkey[2] ^ rkey[1]  
    sw $t2, 8($a0)	# Save rkey[2]
    
    lw $t3, 12($a0)	# Get rkey[3] on $t3
    xor $t3, $t3, $t2	# rkey[3] = rkey[3] ^ rkey[2]
    sw $t3, 12($a0)	# Save rkey[3]
    
    # endkeyupdate
    jr $ra

copyContent:
    # a0 --> address of t
    # a1 --> address of s
    # v0 --> return
    li $t0, 0
    copyLoop:
        add $t2, $a0, $t0
        add $t3, $a1, $t0

        lw $t1, 0($t2)
        sw $t1, 0($t3)

        addi $t0, $t0, 4
        bne $t0, 16, copyLoop

    jr $ra

keyWhitening:
  # a0 --> address of key
  # a1 --> address of message
  # a2 --> address of current state

  li $t0, 0

  whiteningLoop:
    add $t5, $a0, $t0
    add $t6, $a1, $t0
    add $t7, $a2, $t0

    lw $t1, 0($t5)
    lw $t2, 0($t6)

    xor $t3, $t1, $t2

    sw $t3, 0($t7)
    addi $t0, $t0, 4
    
    bne $t0, 16, whiteningLoop

  jr $ra

keySchedule:
    # Save pc for return
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    # Apply keyWhitening
    la $a0, rkey
    la $a1, message
    la $a2, s
    jal keyWhitening

    # Execute the round operation eight times using 8 different round keys

    # ########### ROUND1 ########### #
    # Create round key 1
    la $a0, rkey
    la $a1, rcon
    jal updaterkey

    # Apply round operation on s with round key1
    la $a0, rkey
    la $a1, s
    jal roundOperation
    # ############################## #

    addi $a3, $zero, 4
    ScheduleLoop:
      # Create round key
      la $a0, rkey
      la $t0, rcon
      add $t0, $t0, $a3 # Get next rcon value to $t0
      move $a1, $t0
      jal updaterkey

      # Move content of t to s as the "current state"
      la $a0, t
      la $a1, s
      jal copyContent

      # Apply round operation on (resulting state from last round operation) t with round key2
      la $a0, rkey
      la $a1, s
      jal roundOperation

      addi $a3, $a3, 4
      bne $a3, 32, ScheduleLoop

    la $a0, t
    la $a1, ciphertext
    jal copyContent

    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
    
    
# Take input stream from keyboard
getMessageAndEncrypt:
  # s0 --> inputArray
  # t1 --> number of words
  # t2 --> pointer to inputBuffer
  # t3 --> number of messages
  # t4 --> endline charachter

  li $v0, 4          
  la $a0, prompt
  syscall

  li $v0, 8   
  la $a0, inputBuffer
  li $a1, 640
  syscall

  la $s0, inputArray # Initialize $s0 as the variable pointing to the beginning of inputArray
  li $t4, '\n'  # ASCII value for endline ('\n')

  li $t1, 0  # Initialize counter to 0 for counting words
  la $t2, inputBuffer # Initialize $t2 as the variable pointing to the beginning of inputBuffer
  li $t3, 0 # Initialize counter to 0 for counting messages

  transformInputStream:

    lb $t5, 0($t2) # Load the current character into $t5
    beq $t5, $zero, endTransformationBySignal # Exit the loop if the current character is null  
    beq $t5, $t4, endTransformationBySignal # Exit the loop if the current character is endline ('\n')

    li $t6, 4 # Initialize counter to 4 for counting bytes
    addi $t3, $t3, 1 # Increment the number of messages

  transformSaveLoop:
    li $t7, 0 # Initialize the value to be saved to 0
    li $t9, 4 # Initialize counter to 4 for counting bytes
    beq $t6, 0, transformInputStream # Exit the loop if the counter reaches 0
    addi $t1, $t1, 1 # Increment the number of words
    addi $t6, $t6, -1 # Decrement the counter
  
  # Transform input to proper byte representation in memory
  flipBytes:
    lb $t5, 0($t2) # Load the current character into $t5
    
    beq $t5, $zero, saveTransformation   # Exit the loop if the current character is null
    beq $t5, $t4, saveTransformation   # Exit the loop if the current character is endline ('\n')
    
    addi $t9, $t9, -1 # Decrement the counter
    addi $t3, $t9, 0
    addi $t8, $t5, 0 

    sll $t3, $t3, 3
    sllv $t8, $t8, $t3 # Multiply t8 by 2^t3 (shift left by t3)

    add $t7, $t8, $t7 
    addi $t2, $t2, 1 # Next charachter

    bne $t9, $zero, flipBytes
    
  # Save to the input array
  saveTransformation:
    addi $t5, $t1, -1 
    sll $t5, $t5, 2

    add $t5, $s0, $t5 

    sw $t7, 0($t5) # Save to the current inputArray
    j transformSaveLoop 
    
  allTransformed:
    li $v0, 4
    la $a0, newline
    syscall    
    
  endTransformationBySignal:
    beq $t3, $zero, getInputAndEncrypt # Exit the loop if the counter reaches 0 and go to next 128-bit input

    addi $t3, $t3, -1 
    lw $t5, 0($s0) # Load the value at the current address

    beq $t5, $zero, getInputAndEncrypt
    beq $t5, $t4, getInputAndEncrypt # Exit the loop if the current character is endline ('\n')
    

    li $t0, 0  
  printTransformed:

    # Save number of remaining words and the place we are left in inputArray into stack
    addi $sp, $sp, -12
    sw $t1, 0($sp)
    sw $t2, 4($sp)
    sw $t9, 8($sp)

    lw $a0, 0($s0)
    li $v0, 34
    syscall
    
    lw $t9, 4($s0)       # Load the next word from memory into $t0
    jal print128BitHex        # Call the print128BitHex routine
    
    lw $t9, 8($s0)       # Load the next word from memory into $t0
    jal print128BitHex        # Call the print128BitHex routine
    
    lw $t9, 12($s0)      # Load the final word from memory into $t0
    jal print128BitHex        # Call the print128BitHex routine
    
    # Release stack memory and restore values
    lw $t1, 0($sp)
    lw $t2, 4($sp)
    lw $t9, 8($sp)
    addi $sp, $sp, 12

    addi $t0, $t0, 4 # Increment the counter
    addi $s0, $s0, 16 # Set start to the next word
    j allTransformed

# Loop untill no words left in the inputArray
# Put words from inputArray 4 by 4 into the message 
# jal Roundkey to round the message 
# Print the ciphertext
  getInputAndEncrypt:
    la $s2, inputArray		# Initialize $s2 as the variable pointing to the addres of inputArray we are left with
    add $s1, $t1, $zero		# Initialize $s1 as the number of words
    
  getInputFromMemoryLoop:
    # Print newline
    li $v0, 11     # System call code for print_char
    li $a0, 10     # ASCII value for newline ('\n')
    syscall
    
    beq $s1, $zero, Exit		# If total number of words remaining = 0, exit program
    
    # Get next 4 words in inputArray to message 
    # Get message adress
    la $t2, message
    
    # Load first word from inputArray into message
    lw $t0, 0($s2)		
    sw $t0, 0($t2)
    # Load second word from inputArray into message
    lw $t0, 4($s2)		
    sw $t0, 4($t2)
    # Load third word from inputArray into message
    lw $t0, 8($s2)		
    sw $t0, 8($t2)
    # Load fourth word from inputArray into message
    lw $t0, 12($s2)		
    sw $t0, 12($t2)
    
    # Increase variable pointing to the beginning of inputArray by 4 words
    addi, $s2, $s2, 16
    # Decrease the number of total words remained to extract from inputArray by 4
    addi $s1, $s1, -4

  # Save number of remaining words and the place we are left in inputArray into stack
  addi $sp, $sp, -8
  sw $s1, 0($sp)
  sw $s2, 4($sp)
  
  # update rkey as key (to start new encryption with secret key)
  # Copycontent copies $a0 to $a1
  la $a0, key
  la $a1, rkey
  jal copyContent
  
  jal keySchedule # Encrypt the message

  # Print cyphertext in correct format
  la $t3, ciphertext      # Load the address of the message into $t3
  
  lw $a0, 0($t3)
  li $v0, 34
  syscall
  
  lw $t9, 4($t3)       # Load the next word from memory into $t0
  jal print128BitHex        # Call the print128BitHex routine
  
  lw $t9, 8($t3)       # Load the next word from memory into $t0
  jal print128BitHex        # Call the print128BitHex routine
  
  lw $t9, 12($t3)      # Load the final word from memory into $t0
  jal print128BitHex        # Call the print128BitHex routine
 
  # Release stack memory and restore values
  lw $s1, 0($sp)
  lw $s2, 4($sp)
  addi $sp, $sp, 8
  
  la $t0, ciphertext	# Get the address of ciphertext
  li $t1, 4		# Set counter to 4
	

    
  j getInputFromMemoryLoop

  jr $ra

# Routine to print $t9 as hexadecimal
print128BitHex:
    li $t1, 8               # counter
  print128BitHexLoop:
      rol $t9, $t9, 4        # rotate left 4 bits
      andi $t2, $t9, 0xf     # mask last 4 bits
      blt $t2, 10, print128BitNum  # if less than 10, print as number
      addiu $t2, $t2, 87      # else add 87 (ascii conversion)
      j print128BitAscii
  print128BitNum:
      addiu $t2, $t2, 48      # convert to ascii
  print128BitAscii:
      li $v0, 11              # code for print_char syscall
      move $a0, $t2           # move the character to be printed to $a0
      syscall                 # perform the print_char syscall
      sub $t1, $t1, 1         # decrement the counter
      bnez $t1, print128BitHexLoop    # if the counter is not zero, go back to print_loop
      jr $ra                  # return from print128BitHex

Exit:
li $v0, 10
syscall             # exits the program