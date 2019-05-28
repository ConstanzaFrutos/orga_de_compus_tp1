#include "ant_engine.h"
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "ant_constants.h"
#include "my_assembly.h"

typedef enum colour {RED = CR, GREEN = CG, BLUE = CB, YELLOW = CY, BLACK = CN, WHITE = CW} colour_t;
typedef enum orientation {NORTH = ON, SOUTH = OS, EAST = OE, WEST = OW} orientation_t;
typedef enum rotation {LEFT = RL, RIGHT = RR} rotation_t;

typedef struct {
    uint32_t x;
    uint32_t y;
    orientation_t o;
} ant_t;

typedef struct {
    uint32_t width;
    uint32_t height;
    colour_t **grid;
} square_grid_t;
/****************************************************************************/

int get_quantity(const char *colours) {
	int n = 1;  // Inicialmente hay al menos un color
    for (int i = 0; i < strlen(colours) ; ++i) {
        if (colours[i] == '|')
            ++n;
    }
	return n;
}

void* make_rules(char *spec) {
  int* rules = calloc(get_quantity(spec), sizeof(int));
  for (int i = 0, j = 0; i < strlen(spec) ; ++i, ++j)
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
  for (int i = 0, j = 0; i < strlen(colours) ; ++i, ++j)
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