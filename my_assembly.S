.globl get_current_colour
.globl get_colour_rotation
.globl paint_panel
.globl rotate_ant
.globl move_ant
.globl paint

.text
.abicalls
.align 2
.ent get_current_colour

get_current_colour: 
	#define frame_size 8
    #define frame_fp 4
    #define frame_gp 0
    #define frame_arg2 12
    #define frame_arg1 8
    
    .frame $fp, frame_size, $ra
    subu $sp, $sp, frame_size
    .cprestore 16
    sw $gp, frame_gp($sp)
    sw $fp, frame_fp($sp)
    move  $fp, $sp  # Frame pointer al fondo
      
    sw $a0, frame_arg1($fp) # a0 = *ant
    sw $a1, frame_arg2($fp) # a1 = *grid

    lw $t0, frame_arg1($fp) # t0 = dir mem ant*/
    lw $t1, 0($t0) # t1 = x
    lw $t2, 4($t0) # t2 = y

    lw $t3, frame_arg2($fp) # t3 = dir de mem sq_grid
   
    /* Funcionalidad aca */
    sll $t1, $t1, 2 # x * 4
    sll $t2, $t2, 2 # y * 4

    lw $t8, 8($t3) # t8 = dir mem grid
    addu $t2, $t8, $t2 # t2 = grid + y
    lw $t8, 0($t2)

	addu $t1, $t8, $t1 # t1 = grid + y + x

	lw   $t9, 0($t1) # t9 = dato buscado
	move $v0, $t9

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
    #define gcr_frame_arg3 28
    #define gcr_frame_arg2 24
    #define gcr_frame_arg1 20
    
    .frame $fp, gcr_frame_size, $ra
    subu $sp, $sp, gcr_frame_size
    .cprestore 16
    sw $gp, gcr_frame_gp($sp)
    sw $fp, gcr_frame_fp($sp)
    move  $fp, $sp 
      
    sw $a0, gcr_frame_arg1($fp) # a0 = colour
    sw $a1, gcr_frame_arg2($fp) # a1 = *palette
    sw $a2, gcr_frame_arg3($fp) # a2 = *rules

    lw $t0, gcr_frame_arg1($fp) # t0 = colour

    lw $t1, gcr_frame_arg2($fp) # t1 = dir mem palette
    lw $t8, 4($t1) # t8 = dir mem int array

    lw $t2, gcr_frame_arg3($fp) # t2 = dir mem rules

    /* Funcionalidad aca */
    addu $t3, $zero, $zero  # Inicializo en cero el contador
    addu $t4, $zero, $t8    # t4 = direccion int array (palette)

loop: 
	lw   $t5, 0($t4) # t5 = primer valor array
	beq  $t0, $t5, end  # colour buscado = color array ?
	addu $t3, $t3, 1 # Incremento contador
	addu $t4, $t4, 4 # Incremento posicion en el vector
	b loop

end: 
	sll $t3, $t3, 2 # contador * 4 (pos en arreglo de ints)
	addu $t8, $t2, $t3 # Me muevo en rules
	lw   $t9, 0($t8) # t9 = dato buscado
	move $v0, $t9

    lw $gp, gcr_frame_gp($sp)
    lw $fp, gcr_frame_fp($sp)
    addu $sp, $sp, gcr_frame_size
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
    #define pp_frame_arg4 28
    #define pp_frame_arg3 24
    #define pp_frame_arg2 20
    #define pp_frame_arg1 16
    
    .frame $fp, pp_frame_size, $ra
    subu $sp, $sp, pp_frame_size
    .cprestore 16
    sw $gp, pp_frame_gp($sp)
    sw $fp, pp_frame_fp($sp)
    move  $fp, $sp 
      
    sw $a0, pp_frame_arg1($fp) # a0 = *ant
    sw $a1, pp_frame_arg2($fp) # a1 = *grid
    sw $a2, pp_frame_arg3($fp) # a2 = *palette
    sw $a3, pp_frame_arg4($fp) # a3 = iteration

    lw $t0, pp_frame_arg1($fp) # t0 -> dir mem ant
    lw $t1, 0($t0) # t1 = x
    lw $t2, 4($t0) # t1 = y

    lw $t3, pp_frame_arg2($fp) # t3 = dir mem sq_grid

    lw $t5, pp_frame_arg3($fp) # t5 = dir mem palette
    lw $t4, 0($t5)  # t4 = size (palette)
    lw $t8, 4($t5)  # t8 = dir mem int array (palette)

    lw $t0, pp_frame_arg4($fp)  # t0 = iteration

    /* Funcionalidad aca */
    addi $t0, $t0, 1    # t0 = iteration + 1
    rem $t9, $t0, $t4   # t9 = (it + 1) % size

    sll $t9, $t9, 2 # t9 * 4
    addu $t8, $t8, $t9  # t8 = dir del dato
    lw $t9, 0($t8)  # t9 = new_colour

    sll $t1, $t1, 2 # x * 4
    sll $t2, $t2, 2 # y * 4

    lw $t8, 8($t3)  # t8 = dir mem grid (sq_grid)
    addu $t2, $t8, $t2  # t2 = grid + y
    lw $t8, 0($t2)

	addu $t1, $t8, $t1  # t1 = grid + y + x

	sw  $t9, 0($t1) # Cargo t9 en dir apuntada por t1

    lw $gp, pp_frame_gp($sp)
    lw $fp, pp_frame_fp($sp)
    addu $sp, $sp, pp_frame_size
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
    #define ra_frame_arg2 12
    #define ra_frame_arg1 8
    
    .frame $fp, ra_frame_size, $ra
    subu $sp, $sp, ra_frame_size
    .cprestore 16
    sw $gp, ra_frame_gp($sp)
    sw $fp, ra_frame_fp($sp)
    move  $fp, $sp  # Frame pointer al fondo
      
    sw $a0, ra_frame_arg1($fp)  # a0 = *ant
    sw $a1, ra_frame_arg2($fp)  # a1 = rotation

    lw $t0, ra_frame_arg1($fp)  # t0 = dir mem ant
    lw $t1, 8($t0)  # t1 = o (ant)

    lw $t2, ra_frame_arg2($fp)  # t2 = rotation
   
    /* Funcionalidad aca */ # LEFT = 0 / RIGHT = 1
    addi $t3, $zero, 1  # t3 = SOUTH
    addi $t4, $zero, 2  # t4 = EAST
    addi $t8, $zero, 3  # t8 = WEST

    beq $t1, $zero, north
    beq $t1, $t3, south
    beq $t1, $t4, east
    beq $t1, $t8, west

north:
	beq $t2, $zero, set_west
	b   set_east
south:
	beq $t2, $zero, set_east
	b   set_west
east:
	beq $t2, $zero, set_north
	b   set_south
west:  
	beq $t2, $zero, set_south
	b   set_north

set_north:
	addi $t4, $zero, 0
	b finish
set_south:
	addi $t4, $zero, 1
	b finish
set_east:
	addi $t4, $zero, 2
	b finish
set_west:  
	addi $t4, $zero, 3

finish:
	sw $t4, 8($t0)  # Seteo la orientacion

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
    #define ma_frame_arg2 12
    #define ma_frame_arg1 8
    
    .frame $fp, ma_frame_size, $ra
    subu $sp, $sp, ma_frame_size
    .cprestore 16
    sw $gp, ma_frame_gp($sp)
    sw $fp, ma_frame_fp($sp)
    move  $fp, $sp  # Frame pointer al fondo
      
    sw $a0, ma_frame_arg1($fp)  # a0 = *ant
    sw $a1, ma_frame_arg2($fp)  # a1 = *grid

    lw $t0, ma_frame_arg1($fp)  # t0 = dir memoria ant
    lw $t1, 8($t0)  # t1 = o (ant)

    lw $t2, ma_frame_arg2($fp)  # t2 = dir mem sq_grid
   
    /* Funcionalidad aca */
    addi $t3, $zero, 1  # t3 = SOUTH
    addi $t4, $zero, 2  # t4 = EAST
    addi $t8, $zero, 3  # t8 = WEST

    beq $t1, $zero, north_ma
    beq $t1, $t3, south_ma
    beq $t1, $t4, east_ma
    beq $t1, $t8, west_ma

north_ma:
	lw $t5, 4($t0)  # t5 = y (ant)
	beq $t5, $zero, y_goes_around
	b   decrement_y
south_ma:
	lw $t5, 4($t0)  # t5 = y (ant)
	lw $t4, 4($t2)  # t4 =  h (sq_grid)
	subu $t4, $t4, 1    # t4 = h - 1
	beq $t5, $t4, y_equals_cero
	b increment_y
east_ma:
	lw $t5, 0($t0)  # t5 = x (ant)
	lw $t4, 0($t2)  # t4 = w (sq_grid)
	subu $t4, $t4, 1    # t4 = w - 1
	beq $t5, $t4, x_equals_cero
	b increment_x
west_ma:  
	lw $t5, 0($t0)  # t5 = x (ant)
	beq $t5, $zero, x_goes_around
	b   decrement_x

y_goes_around:
	lw $t4, 4($t2)  # t4 = h
	subu $t4, $t4, 1    # t4 = h - 1
	sw $t4, 4($t0)
	b finish_ma
decrement_y:
	subu $t5, $t5, 1    # t5 = y - 1
	sw $t5, 4($t0)
	b finish_ma
y_equals_cero:
	sw $zero, 4($t0)
	b finish_ma
increment_y:  
	addi $t5, $t5, 1    # t5 = y + 1
	sw $t5, 4($t0)
	b finish_ma
x_equals_cero:
	sw $zero, 0($t0)
	b finish_ma
increment_x:  
	addi $t5, $t5, 1    # t5 = x + 1
	sw $t5, 0($t0)
	b finish_ma
decrement_x:
	subu $t5, $t5, 1    # t5 = x - 1
	sw $t5, 0($t0)
	b finish_ma
x_goes_around:
	lw $t4, 0($t2)  # t4 = w
	subu $t4, $t4, 1    # t4 = w - 1
	sw $t4, 0($t0)
	b finish_ma		

finish_ma:
    lw $gp, ma_frame_gp($sp)
    lw $fp, ma_frame_fp($sp)
    addu $sp, $sp, ma_frame_size
    jr $ra

.end move_ant


.text
.abicalls
.align 2
.ent paint

paint:
	#define p_frame_size 48
	#define p_frame_ra 40
    #define p_frame_fp 36
    #define p_frame_gp 32
    #define p_frame_arg5 64
    #define p_frame_arg4 60
    #define p_frame_arg3 56
    #define p_frame_arg2 52
    #define p_frame_arg1 48

    .frame $fp, p_frame_size, $ra
    subu $sp, $sp, p_frame_size
    .cprestore 16
    sw $gp, p_frame_gp($sp)
    sw $fp, p_frame_fp($sp)
    sw $ra, p_frame_ra($sp)
    move  $fp, $sp  # Frame pointer al fondo

    sw $a0, p_frame_arg1($fp)   # a0 = *ant
    sw $a1, p_frame_arg2($fp)   # a1 = *grid
    sw $a2, p_frame_arg3($fp)   # a2 = *palette
    sw $a3, p_frame_arg4($fp)   # a3 = *rules

    addu $t6, $zero, $zero  # t6 = contador en 0
    lw $t7, p_frame_arg5($fp)  # t7 = arg4 (cantidad iteraciones)
    beq $t7, $zero, end_paint
    b paint_loop

paint_loop:
    /* get_current_colour */
    jal get_current_colour  # $a0 y $a1 son sus argumentos, no necesito modif.
    addu $t2, $v0, $zero

    /* get_colour_rotation */
    move $a0, $v0   # a0 = color retornado
    lw $t3, p_frame_arg3($fp)
    move $a1, $t3   # a1 = *palette
    lw $t3, p_frame_arg4($fp)
    move $a2, $t3   # a2 = *rules
    jal get_colour_rotation

    /* rotate_ant */
    lw $t3, p_frame_arg1($fp)
    move $a0, $t3   # a0 = *ant
    move $a1, $v0   # a1 = rotacion retornada
    
    jal rotate_ant

    /* paint_panel */
    lw $t3, p_frame_arg2($fp)
    move $a1, $t3   # a1 = *grid. a0 = *ant (ya seteado)
    addu $t3, $fp, p_frame_arg3
    lw $t3, p_frame_arg3($fp)
    move $a2, $t3   # a2 = *palette
    move $a3, $t6   # a3 = numero iteracion
    jal paint_panel

    jal move_ant    # a1 = *grid. a0 = *ant (ya seteados)

    addi $t6, $t6, 1    # Incremento contador
    beq $t6, $t7, end_paint
    b paint_loop

end_paint:
    lw $t3, p_frame_arg4($fp)
    move $a3, $t3   # Vuelvo a poner a3 = *rules

    lw $t3, p_frame_arg2($fp)
    move $v0, $t3   # v0 = *grid

    lw $gp, p_frame_gp($sp)
    lw $fp, p_frame_fp($sp)
    lw $ra, p_frame_ra($sp)
    addu $sp, $sp, p_frame_size
    jr $ra

.end paint
