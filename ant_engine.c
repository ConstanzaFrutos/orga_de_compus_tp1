#include "ant_engine.h"

#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

#include "ant_constants.h" //No se si se puede incluir o que

//ESTO NO SE SI PUEDE IR ACA; SINO NO SE COMO HACERLO
typedef enum colour {RED = CR, GREEN = CG, BLUE = CB, YELLOW = CY, BLACK = CN, WHITE = CW} colour_t;
typedef enum orientation {NORTH = ON, SOUTH = OS, EAST = OE, WEST = OW} orientation_t;
typedef enum rotation {LEFT = RL, RIGHT = RR} rotation_t;

typedef struct {
    uint32_t x, y;
    orientation_t o;
} ant_t;

typedef struct {
    uint32_t width;
    uint32_t height;
    colour_t **grid;
} square_grid_t;
////////////////////////////////////////////////////////////////////////////


int get_colour_rotation(int colour, void* palette, void* rules){
	int i = 0;
	int* palette_int = (int*) palette;
	int* rules_int = (int*) rules;
	int aux = palette_int[i];
	while (aux != colour){
		i++;
		aux = palette_int[i];
	}
	return rules_int[i];
}

int get_current_colour(void* ant_void, void* grid){
	square_grid_t* square_grid = (square_grid_t*) grid;
	ant_t* ant = (ant_t*) ant_void;

	int current = square_grid->grid[ant->y][ant->x];
	return current;
}

void rotate_ant(void* ant_void, int rotation){
	ant_t* ant = (ant_t*) ant_void;
	int orientation = ant->o;
	if (orientation == ON){
		if (rotation == RL)
			ant->o = OE;
		else 
			ant->o = OW;
	} else if (orientation == OS){
		if (rotation == RL)
			ant->o = OW;
		else 
			ant->o = OE;
	} else if (orientation == OE){
		if (rotation == RL)
			ant->o = OS;
		else 
			ant->o = ON;
	} else {
		if (rotation == RL)
			ant->o = ON;
		else 
			ant->o = OS;
	}
}

void move_ant(void* ant_void){
	ant_t* ant = (ant_t*) ant_void;
	int orientation = ant->o;
	if (orientation == ON){
		ant->y --;
	} else if (orientation == OS){
		ant->y ++;
	} else if (orientation == OW){
		ant->x ++;
	} else {
		ant->x --;
	}
}

void paint_panel(void* ant_void, void* grid, void* palette, int iteration){
	square_grid_t* square_grid = (square_grid_t*) grid;
	ant_t* ant = (ant_t*) ant_void;
	int* palette_int = (int*) palette;

	int new_colour = palette_int[iteration+1]; //Hay que usar mod, pero no se como
	                                         //calcular la long de palette
	square_grid->grid[ant->y][ant->x] = new_colour;
}

void*
paint(void *ant, void *grid, void *palette, void *rules,  uint32_t iterations)
{
  for (int i=0; i<iterations; ++i){
  	int current = get_current_colour(ant, grid);
  	int rotation = get_colour_rotation(current, palette, rules);
  	rotate_ant(ant, rotation);
  	paint_panel(ant, grid, palette, i);
  	move_ant(ant);
  }
  
  return grid;
}

int get_quantity(char* colours){
	char aux = '\0';
	int n = 0;
	int i = 0;
	do {
		aux = colours[i];
		if (aux == '|')
			n ++;
		i++;
	} while (aux != '\0');

	return n + 1;
}

void*
make_rules(char *spec)
{
  int n = get_quantity(spec);	
  int* rules = calloc(n, sizeof(int));
  char aux = '\0';
  int p = 0;
  int i = 0;

  do{
  	aux = spec[i];
  	if (aux == 'L'){
  		rules[p] = RL;
  	} else if (aux == 'R'){
  		rules[p] = RR;
  	} else {
  		p--;
  	}
  	p++;
  	i++;
  } while (aux != '\0');

  return (void*) rules;
}

void*
make_palette(char *colours)
{
  int n = get_quantity(colours);	
  int* pallete = calloc(n, sizeof(int));
  char aux = '\0';
  int p = 0;
  int i = 0;

  do{
  	aux = colours[i];
  	if (aux == 'R'){
  		pallete[p] = CR;
  	} else if (aux == 'G'){
  		pallete[p] = CG;
  	} else if (aux == 'B'){
  		pallete[p] = CB;
  	} else if (aux == 'Y'){
  		pallete[p] = CY;
  	} else if (aux == 'N'){
  		pallete[p] = CN;
  	} else if (aux == 'W'){
  		pallete[p] = CW;
  	} else {
  		p--;
  	}
  	p++;
  	i++;
  } while (aux != '\0');

  return (void*) pallete;
}
