#ifndef __ANT_ENGINE_H__
#define __ANT_ENGINE_H__

#include <stdio.h>
#include <unistd.h>

void* paint(void *ant, void *grid, void *palette, void *rules,  uint32_t iterations);

#define panic(s)       \
  do {                 \
    fprintf(stderr, "%s: %s\n", __FUNCTION__, s);\
    exit(1);            \
  } while(0);


#endif /* __ANT_ENGINE_H__ */

