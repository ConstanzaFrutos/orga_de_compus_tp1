#ifndef __ARTIST_ANT_H__
#define __ARTIST_ANT_H__

#include <unistd.h>

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

void* paint(void *ant, void *grid, void *palette, void *rules,  uint32_t iterations);

void* make_rules(char *spec);

void* make_palette(char *colours);

void* make_grid(uint32_t w, uint32_t h, colour_t c);

void* make_ant(uint32_t xini, uint32_t yini);

void grid_out();

uint32_t as_int(void *arg, uint32_t from, uint32_t to);

#endif /* __ARTIST_ANT_H__ */

