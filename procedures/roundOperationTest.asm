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