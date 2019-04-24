#include "ant_engine.h"

#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include "ant_constants.h"

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
/****************************************************************************/

int get_colour_rotation(int colour, void* palette, void* rules) {
	int pos = 0;
	palette_t* palette_int = (palette_t*) palette;
	int* rules_int = (int*) rules;
	for (; palette_int->colours[pos] != colour; ++pos) {}
	return rules_int[pos];
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
/*todo QUE CUANDO LLEGA AL FINAL PEGUE LA VUELTA*/
void move_ant(void* ant_void){
	ant_t* ant = (ant_t*) ant_void;
    (ant->o == ON) ? --ant->y : ((ant->o == OS) ? ++ant->y : (ant->o == OW) ? ++ant->x : --ant->x);
}

void paint_panel(void* ant_void, void* grid, void* palette, int iteration){
	square_grid_t* square_grid = (square_grid_t*) grid;
	ant_t* ant = (ant_t*) ant_void;
	palette_t* palette_struct = (palette_t*) palette;

	size_t pos = (iteration + 1) % palette_struct->size;
	int new_colour = palette_struct->colours[pos];
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
  palette_destroy(palette);
  free(rules);
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
  palette_t* palette = create_palette(colours);
  for (int i = 0, j = 0; colours[i] ; ++i, ++j)
      switch (colours[i]) {
          case 'R':
              palette->colours[j] = CR;
              break;
          case 'G':
              palette->colours[j] = CG;
              break;
          case 'B':
              palette->colours[j] = CB;
              break;
          case 'Y':
              palette->colours[j] = CY;
              break;
          case 'N':
              palette->colours[j] = CN;
              break;
          case 'W':
              palette->colours[j] = CW;
              break;
          default:
              --j;
      }
    return (void*) palette;
}

palette_t* create_palette(char* colours) {
    palette_t* palette = malloc(sizeof(palette_t));
    palette->size = get_quantity(colours);
    palette->colours = calloc(palette->size, sizeof(int));
    return palette;
}

void palette_destroy(palette_t* palette) {
    free(palette->colours);
    free(palette);
}