.globl get_current_colour
.globl get_colour_rotation
.globl paint_panel

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
   
    /* Funcionalidad aca */
    sll $t1, $t1, 2 # x * 4
    sll $t2, $t2, 2 # y * 4

    lw $t8, 8($t3) #direccion de mem de grid
    addu $t1, $t8, $t1 # grid + x 
    lw $t8, 0($t1)

	addu $t2, $t8, $t2 # t7 = grid + y + x 

	lw   $t9, 0($t2) #cargo en t9 el dato
	move $v0, $t9  #Guardo en v0 lo que devuelvo

    lw $gp, frame_gp($sp)
    lw $fp, frame_fp($sp)
    addu $sp, $sp, frame_size
    jr $ra

.end get_current_colour


.text
.abicalls
.align 2
.ent get_colour_rotation

get_colour_rotation: 
	#define gcr_frame_size 24
    #define gcr_frame_fp 20
    #define gcr_frame_gp 16
    #define gcr_frame_3arg 32
    #define gcr_frame_2arg 28
    #define gcr_frame_1arg 24
    
    .frame $fp, gcr_frame_size, $ra
    subu $sp, $sp, gcr_frame_size
    .cprestore 16
    sw $gp, gcr_frame_gp($sp)
    sw $fp, gcr_frame_fp($sp)
    move  $fp, $sp 
      
    sw $a0, gcr_frame_1arg($fp) /* Primer argumento colour*/
    sw $a1, gcr_frame_2arg($fp) /* Segundo argumento palette*/
    sw $a2, gcr_frame_3arg($fp) /* Tercer argumento rules*/

    lw $t0, gcr_frame_1arg($fp) /* t0 -> dir de memoria de colour*/

    lw $t1, gcr_frame_2arg($fp) /* t1 -> dir de memoria de palette*/
    lw $t8, 4($t1) /* t8 -> dir de memoria del array*/

    lw $t2, gcr_frame_3arg($fp) /* t2 -> dir de memoria de rules*/

    /* Funcionalidad aca */
    addu $t3, $zero, $zero #Inicializo con cero el contador

    addu $t4, $zero, $t8 #Pongo en t4 la direccion de palette

loop: 
	lw   $t5, 0($t4) #En t5 pongo el valor 
	beq  $t0, $t5, end  
	addu $t3, $t3, 1 #Incremento el contador
	addu $t4, $t4, 4 #Incremento la posicion en el vector
	b loop #Agregar que de la vuelta?

end: 
	sll $t3, $t3, 2 #Multiplico por 4 el contador
	addu $t6, $t2, $t3 #me muevo en rules
	lw   $t7, 0($t6) #cargo en t9 el dato
	move $v0, $t7  #Guardo en v0 lo que devuelvo

    lw $gp, gcr_frame_gp($sp)
    lw $fp, gcr_frame_fp($sp)
    addu $sp, $sp, frame_size
    jr $ra

.end get_colour_rotation


.text
.abicalls
.align 2
.ent paint_panel

paint_panel: 
	#define pp_frame_size 24
    #define pp_frame_fp 20
    #define pp_frame_gp 16
    #define pp_frame_4arg 36
    #define pp_frame_3arg 32
    #define pp_frame_2arg 28
    #define pp_frame_1arg 24
    
    .frame $fp, pp_frame_size, $ra
    subu $sp, $sp, pp_frame_size
    .cprestore 16
    sw $gp, pp_frame_gp($sp)
    sw $fp, pp_frame_fp($sp)
    move  $fp, $sp 
      
    sw $a0, pp_frame_1arg($fp) /* Primer argumento ant*/
    sw $a1, pp_frame_2arg($fp) /* Segundo argumento grid*/
    sw $a2, pp_frame_3arg($fp) /* Tercer argumento palette*/
    sw $a3, pp_frame_4arg($fp) /* Cuarto argumento iteration*/

    lw $t0, pp_frame_1arg($fp) /* t0 -> dir de memoria de ant*/
    lw $t1, 0($t0) #t1 -> x
    lw $t2, 4($t0) #t1 -> y

    lw $t3, pp_frame_2arg($fp) /* t3-> dir de memoria de grid*/

    lw $t5, pp_frame_3arg($fp) /* t5 -> dir de memoria de size (palette)*/
    lw $t4, 0($t5) #size
    lw $t6, 4($t5) /* t6 -> dir de memoria del array (palette)*/

    lw $t7, pp_frame_4arg($fp) /* t7 -> dir de memoria de iteration*/

    /* Funcionalidad aca */
    /* size_t pos = (iteration + 1) % palette_struct->size; */
    addi $t7, $t7, 1 #t8 = iteration + 1
    rem $t9, $t7, $t4 #t9 = (it + 1) % size

    /* int new_colour = palette_struct->colours[pos]; */
    sll $t9, $t9, 2 #mult por 4
    addu $t8, $t6, $t9 #t8 -> dir del elemento
    lw $t9, 0($t8) #Cargo en t9 el elemento (new_colour) 

    /* square_grid->grid[ant->y][ant->x] = new_colour; */
    sll $t1, $t1, 2 # x * 4
    sll $t2, $t2, 2 # y * 4

    lw $t8, 8($t3) #direccion de mem de grid
    addu $t2, $t8, $t2 # grid + x 
    lw $t8, 0($t2)

	addu $t1, $t8, $t1 # t7 = grid + y + x 

	sw  $t9, 0($t1) #Cargo el valor en memoria

    lw $gp, pp_frame_gp($sp)
    lw $fp, pp_frame_fp($sp)
    addu $sp, $sp, frame_size
    jr $ra

.end paint_panel