.globl get_current_colour

.text
.abicalls
.align 2
.ent get_current_colour

get_current_colour: 
	#define frame_size 24
    #define frame_fp 20
    #define frame_gp 16
    #define frame_2arg 28
    #define frame_1arg 24
    
    .frame $fp, frame_size, $ra
    subu $sp, $sp, frame_size
    .cprestore 16
    sw $gp, frame_gp($sp)
    sw $fp, frame_fp($sp)
    move  $fp, $sp /* frame pointer al fondo */
      
    sw $a0, frame_1arg($fp) /* Primer argumento (ant)*/
    sw $a1, frame_2arg($fp) /* Segundo argumento (grid)*/

    lw $t0, frame_1arg($fp) /* t0 -> dir de memoria de ant*/
    lw $t1, 0($t0) # t1 = x
    lw $t2, 4($t0) # t2 = y

    lw $t3, frame_2arg($fp) /* t3 -> dir de memoria de grid*/
    lw $t4, 0($t3) # t4 = w
    lw $t5, 4($t3) #t5 = h
    lw $t6, 8($t3) #t6 = grid
   
    /* Funcionalidad aca */
	subu $t7, $t5, $t1 # t6 = h-y
	subu $t7, $t7, 1 # t6 = h-y-1

	mul  $t7, $t4, $t7 # W*(h-y-1)

	addu $t7, $t7, $t1 # t7 = w*(h-y-1) + x 
	sll $t7, $t7, 2 #multiplico por 4
	
	addi $t8, $t3, 8 #direccion de mem de grid
	addu $t8, $t8, $t7 #direccion de mem del dato
	lw   $t9, 0($t8) #cargo en t9 el dato
	move $v0, $t9  #Guardo en v0 lo que devuelvo

    lw $gp, frame_gp($sp)
    lw $fp, frame_fp($sp)
    addu $sp, $sp, frame_size
    jr $ra

.end get_current_colour
								
