.globl get_current_colour
.globl get_colour_rotation
.globl paint_panel
.globl rotate_ant
.globl move_ant

.text
.abicalls
.align 2
.ent get_current_colour

get_current_colour: 
	#define frame_size 8
    #define frame_fp 4
    #define frame_gp 0
    #define frame_2arg 12
    #define frame_1arg 8
    
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
    addu $t2, $t8, $t2 # grid + y
    lw $t8, 0($t2)

	addu $t1, $t8, $t1 # t7 = grid + y + x

	lw   $t9, 0($t1) #cargo en t9 el dato
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
	#define gcr_frame_size 16
    #define gcr_frame_fp 12
    #define gcr_frame_gp 8
    #define gcr_frame_3arg 28
    #define gcr_frame_2arg 24
    #define gcr_frame_1arg 20
    
    .frame $fp, gcr_frame_size, $ra
    subu $sp, $sp, gcr_frame_size
    .cprestore 16
    sw $gp, gcr_frame_gp($sp)
    sw $fp, gcr_frame_fp($sp)
    move  $fp, $sp 
      
    sw $a0, gcr_frame_1arg($fp) /* Primer argumento colour */
    sw $a1, gcr_frame_2arg($fp) /* Segundo argumento palette */
    sw $a2, gcr_frame_3arg($fp) /* Tercer argumento rules */

    lw $t0, gcr_frame_1arg($fp) /* t0 -> valor de colour */

    lw $t1, gcr_frame_2arg($fp) /* t1 -> dir de memoria de palette */
    lw $t8, 4($t1) /* t8 -> dir de memoria del array */

    lw $t2, gcr_frame_3arg($fp) /* t2 -> dir de memoria de rules */

    /* Funcionalidad aca */
    addu $t3, $zero, $zero # Inicializo con cero el contador

    addu $t4, $zero, $t8 # Pongo en t4 la direccion de palette

loop: 
	lw   $t5, 0($t4) # En t5 pongo el valor
	beq  $t0, $t5, end  
	addu $t3, $t3, 1 # Incremento el contador
	addu $t4, $t4, 4 # Incremento la posicion en el vector
	b loop # Agregar que de la vuelta?

end: 
	sll $t3, $t3, 2 # Multiplico por 4 el contador (por ser arreglo de ints)
	addu $t6, $t2, $t3 # Me muevo en rules
	lw   $t7, 0($t6) # Cargo en t7 el dato
	move $v0, $t7  # Guardo en v0 lo que devuelvo

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
	#define pp_frame_size 16
    #define pp_frame_fp 12
    #define pp_frame_gp 8
    #define pp_frame_4arg 28
    #define pp_frame_3arg 24
    #define pp_frame_2arg 20
    #define pp_frame_1arg 16
    
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
    lw $t4, 0($t5) # Size
    lw $t6, 4($t5) /* t6 -> dir de memoria del array (palette)*/

    lw $t7, pp_frame_4arg($fp) /* t7 -> valor de iteration*/

    /* Funcionalidad aca */
    /* size_t pos = (iteration + 1) % palette_struct->size; */
    addi $t7, $t7, 1 # t8 = iteration + 1
    rem $t9, $t7, $t4 # t9 = (it + 1) % size

    /* int new_colour = palette_struct->colours[pos]; */
    sll $t9, $t9, 2 # Multiplico por 4
    addu $t8, $t6, $t9 # t8 -> dir del elemento
    lw $t9, 0($t8) #Cargo en t9 el elemento (new_colour) 

    /* square_grid->grid[ant->y][ant->x] = new_colour; */
    sll $t1, $t1, 2 # x * 4
    sll $t2, $t2, 2 # y * 4

    lw $t8, 8($t3) # Direccion de mem de grid
    addu $t2, $t8, $t2 # grid + y
    lw $t8, 0($t2)

	addu $t1, $t8, $t1 # t7 = grid + y + x

	sw  $t9, 0($t1) #Cargo el valor en memoria

    lw $gp, pp_frame_gp($sp)
    lw $fp, pp_frame_fp($sp)
    addu $sp, $sp, frame_size
    jr $ra

.end paint_panel


.text
.abicalls
.align 2
.ent rotate_ant

rotate_ant: 
	#define ra_frame_size 8
    #define ra_frame_fp 4
    #define ra_frame_gp 0
    #define ra_frame_2arg 12
    #define ra_frame_1arg 8
    
    .frame $fp, ra_frame_size, $ra
    subu $sp, $sp, ra_frame_size
    .cprestore 16
    sw $gp, ra_frame_gp($sp)
    sw $fp, ra_frame_fp($sp)
    move  $fp, $sp /* frame pointer al fondo */
      
    sw $a0, ra_frame_1arg($fp) /* Primer argumento (ant)*/
    sw $a1, ra_frame_2arg($fp) /* Segundo argumento (rotation)*/

    lw $t0, ra_frame_1arg($fp) /* t0 -> dir de memoria de ant*/
    lw $t1, 8($t0) # t1 = o

    lw $t3, ra_frame_2arg($fp) /* t3 -> valor de rotation (int)*/
   
    /* Funcionalidad aca */
    addi $t4, $zero, 1
    addi $t6, $zero, 2
    addi $t7, $zero, 3

    seq $t5, $t3, $zero #Si rotation es 0 -> $t5 = 1

    beq $t1, $zero, north
    beq $t1, $t4, south
    beq $t1, $t6, east
    beq $t1, $t7, west

north:
	beq $t5, $t4, set_west #Si rot = 1 -> set_west
	b   set_east
south:
	beq $t5, $t4, set_east
	b   set_west
east:
	beq $t5, $t4, set_north
	b   set_south
west:  
	beq $t5, $t4, set_south
	b   set_north

set_north:
	addi $t6, $zero, 0
	b finish
set_south:
	addi $t6, $zero, 1
	b finish
set_east:
	addi $t6, $zero, 2
	b finish
set_west:  
	addi $t6, $zero, 3

finish:
	sw $t6, 8($t0) #Seteo la orientacion

    lw $gp, ra_frame_gp($sp)
    lw $fp, ra_frame_fp($sp)
    addu $sp, $sp, ra_frame_size
    jr $ra

.end rotate_ant



.text
.abicalls
.align 2
.ent move_ant

move_ant: 
	#define ma_frame_size 8
    #define ma_frame_fp 4
    #define ma_frame_gp 0
    #define ma_frame_2arg 12
    #define ma_frame_1arg 8
    
    .frame $fp, ma_frame_size, $ra
    subu $sp, $sp, ma_frame_size
    .cprestore 16
    sw $gp, ma_frame_gp($sp)
    sw $fp, ma_frame_fp($sp)
    move  $fp, $sp /* frame pointer al fondo */
      
    sw $a0, ma_frame_1arg($fp) /* Primer argumento (ant)*/
    sw $a1, ma_frame_2arg($fp) /* Segundo argumento (grid)*/

    lw $t0, ma_frame_1arg($fp) /* t0 -> dir de memoria de ant*/
    lw $t1, 8($t0) # t1 = o

    lw $t3, ma_frame_2arg($fp) /* t3 -> dir de memoria de grid*/
   
    /* Funcionalidad aca */
    addi $t4, $zero, 1 # t4 = 1 south
    addi $t6, $zero, 2 # east
    addi $t7, $zero, 3 # west

    beq $t1, $zero, north_ma
    beq $t1, $t4, south_ma
    beq $t1, $t6, east_ma
    beq $t1, $t7, west_ma

north_ma:
	lw $t5, 4($t0) #cargo y
	beq $t5, $zero, y_goes_around #Si y = 0 -> 
	b   decrement_y
south_ma:
	lw $t5, 4($t0) #cargo y
	lw $t6, 4($t3) #cargo h
	subu $t6, $t6, 1 # t6 = h - 1
	beq $t5, $t6, y_equals_cero
	b increment_y
east_ma:
	lw $t5, 0($t0) #cargo x
	lw $t6, 0($t3) #cargo w
	subu $t6, $t6, 1 # t6 = w - 1
	beq $t5, $t6, x_equals_cero
	b increment_x
west_ma:  
	lw $t5, 0($t0) #cargo x
	beq $t5, $zero, x_goes_around #Si x = 0 -> 
	b   decrement_x

y_goes_around:
	/* ant->y = square_grid->height - 1 */
	lw $t6, 4($t3) # t6 = h
	subu $t6, $t6, 1 # t6 = h - 1
	sw $t6, 4($t0)
	b finish_ma
decrement_y:
	subu $t5, $t5, 1 # t5 = y - 1
	sw $t5, 4($t0)
	b finish_ma
y_equals_cero:
	sw $zero, 4($t0)
	b finish_ma
increment_y:  
	addi $t5, $t5, 1
	sw $t5, 4($t0)
	b finish_ma
x_equals_cero:
	sw $zero, 0($t0)
	b finish_ma
increment_x:  
	addi $t5, $t5, 1
	sw $t5, 0($t0)
	b finish_ma
decrement_x:
	subu $t5, $t5, 1 # t5 = x - 1
	sw $t5, 0($t0)
	b finish_ma
x_goes_around:
	/* ant->x = square_grid->width - 1 */
	lw $t6, 0($t3) # t6 = w
	subu $t6, $t6, 1 # t6 = w - 1
	sw $t6, 0($t0)
	b finish_ma		

finish_ma:

    lw $gp, ma_frame_gp($sp)
    lw $fp, ma_frame_fp($sp)
    addu $sp, $sp, ra_frame_size
    jr $ra

.end move_ant

