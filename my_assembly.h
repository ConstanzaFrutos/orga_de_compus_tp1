int get_colour_rotation(int colour, void* palette, void* rules);

int get_current_colour(void* ant_void, void* grid);

void rotate_ant(void* ant_void, int rotation);

void paint_panel(void* ant_void, void* grid, void* palette, int iteration);

//void move_ant(void* ant_void, void* grid);

//void* paint(void *ant, void *grid, void *palette, void *rules,  uint32_t iterations);