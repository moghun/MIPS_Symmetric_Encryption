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