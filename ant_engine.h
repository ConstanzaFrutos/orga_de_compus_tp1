#ifndef __ANT_ENGINE_H__
#define __ANT_ENGINE_H__

#include <stdint.h>

#include <stdio.h>
#include <unistd.h>

typedef struct pallete {
    int* colours;
    size_t size;
} palette_t;

palette_t* create_palette(char* colours);

void palette_destroy(palette_t* palette);

void* paint(void *ant, void *grid, void *palette, void *rules,  uint32_t iterations);

#define panic(s)       \
  do {                 \
    fprintf(stderr, "%s: %s\n", __FUNCTION__, s);\
    exit(1);            \
  } while(0);


#endif /* __ANT_ENGINE_H__ */

