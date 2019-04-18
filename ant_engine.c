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


int get_colour_rotation(int colour, void* palette, void* rules) {
	int i = 0;
	int* palette_int = (int*) palette;
	int* rules_int = (int*) rules;
	for (; palette_int[i] != colour; ++i) {}
	return rules_int[i];
}

int get_current_colour(void* ant_void, void* grid) {
	square_grid_t* square_grid = (square_grid_t*) grid;
	ant_t* ant = (ant_t*) ant_void;

    return square_grid->grid[ant->y][ant->x];
}

void rotate_ant(void* ant_void, int rotation){
	ant_t* ant = (ant_t*) ant_void;
	switch (ant->o) {
        case ON:
            (rotation == RL) ? (ant->o = OE) : (ant->o = OW);
            break;
        case OS:
            (rotation == RL) ? (ant->o = OW) : (ant->o = OE);
            break;
	    case OE:
            (rotation == RL) ? (ant->o = OS) : (ant->o = ON);
	        break;
        case OW:
            (rotation == RL) ? (ant->o = ON) : (ant->o = OS);
            break;
	}
}

void move_ant(void* ant_void){
	ant_t* ant = (ant_t*) ant_void;
    (ant->o == ON) ? --ant->y : ((ant->o == OS) ? ++ant->y : (ant->o == OW) ? ++ant->x : --ant->x);
}

void paint_panel(void* ant_void, void* grid, void* palette, int iteration){
	square_grid_t* square_grid = (square_grid_t*) grid;
	ant_t* ant = (ant_t*) ant_void;
	int* palette_int = (int*) palette;

	int new_colour = palette_int[iteration+1]; //Hay que usar mod, pero no se como
	                                         //calcular la long de palette
	square_grid->grid[ant->y][ant->x] = new_colour;
}

void* paint(void *ant, void *grid, void *palette, void *rules,  uint32_t iterations) {
  for (int i=0; i<iterations; ++i){
  	int current = get_current_colour(ant, grid);
  	int rotation = get_colour_rotation(current, palette, rules);
  	rotate_ant(ant, rotation);
  	paint_panel(ant, grid, palette, i);
  	move_ant(ant);
  }
  return grid;
}

int get_quantity(const char *colours) {
	int n = 1;  // Inicialmente hay al menos un color
    for (int i = 0; colours[i] ; ++i)
        if (colours[i] == '|')
            ++n;
	return n;
}

void* make_rules(char *spec) {
  int* rules = calloc(get_quantity(spec), sizeof(int));
  for (int i = 0, j = 0; spec[i] ; ++i, ++j)
    switch (spec[i]) {
        case 'L':
            rules[j] = RL;
            break;
        case 'R':
            rules[j] = RR;
            break;
        default:
            --j;
            break;
    }
  return (void*) rules;
}

void* make_palette(char *colours) {
  int* pallete = calloc(get_quantity(colours), sizeof(int));
  for (int i = 0, j = 0; colours[i] ; ++i, ++j)
      switch (colours[i]) {
          case 'R':
              pallete[j] = CR;
              break;
          case 'G':
              pallete[j] = CG;
              break;
          case 'B':
              pallete[j] = CB;
              break;
          case 'Y':
              pallete[j] = CY;
              break;
          case 'N':
              pallete[j] = CN;
              break;
          case 'W':
              pallete[j] = CW;
              break;
          default:
              --j;
      }
  return (void*) pallete;
}
