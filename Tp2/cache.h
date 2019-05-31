#ifndef CACHE_H
#define CACHE_H

//Post: La memoria principal simulada queda 
//inicializada en 0, los bloques de caché como 
//inválidos y la tasa de misses en 0.
void init();

//Pre: recibe una address como unsigned int
//Post: devuelve el offset del byte del bloque de memoria al que 
//mapea la dirección address.
unsigned int get_offset (unsigned int address);

//Pre: recibe una address como unsigned int
//Post: devuelve el conjunto de caché al que
//mapea la dirección address.
unsigned int find_set(unsigned int address);

//Pre: Recibe setnum como unsigned int.
//Post: devuelve la vía en la que esta el bloque mas
//"viejo" dentro de un conjunto, utilizando el campo
//correspondiente de los metadatos de los bloques del conjunto.
unsigned int select_oldest(unsigned int setnum);

//Pre: Recine un blocknum, la vía y el conjunto.
//Lee el bloque blocknum de memoria y lo guarda en el conjunto y 
//vía indicados en la memoria caché.
//Post: Deja a la caché en el estado indicado.
void read_tocache(unsigned int blocknum, unsigned int way, unsigned int set);

//Pre:
//Post:
void write_tocache(unsigned int address, unsigned char);

//Pre: Recibe una dirección.
//Busca el valor del byte correspondiente a la posición 
//address en la caché. Si no se encuentra carga el bloque.
//Post: Retorna el valor del byte almacenado en la 
//dirección indicada.
unsigned char read_byte(unsigned int address);

//Pre: Recibe una dirección y un valor.
//Escribe el valor value en la posición address de memoria,
//y en la posición correcta del bloque que corresponde a address,
//si el bloque se encuentra en la caché. Si no se encuentra, 
//debe escribir el valor solamente en la memoria.
void write_byte(unsigned int address, unsigned char value);

//Post: devuelve el porcentaje de misses desde que se inicializó la caché.
float get_miss_rate();

void print_cache();

void print_memoria();

#endif //CACHE_H