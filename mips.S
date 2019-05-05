.text
.align 2
.globl get_current_colour

get_current_colour: 
        subu $sp, $sp, 16
				sw $fp, 12($sp)
				sw $gp, 8($sp)
				
				addi $t1, $a0, 4 #y
				addi $t3, $a1, 0 #w
				addi $t4, $a1, 4 #h
				subu $t5, $t4, $t1
				subi $t4, $t4, 1

mult:
        addu $t4, $t4, $t4
				subu $t5, $t3, 1
				bne $zero mult

				addu $t6, $t4, $t1
				addu $v0, $a1, 12  #Guardo en v0 lo que devuelvo
				j ra

.end get_current_colour
								
