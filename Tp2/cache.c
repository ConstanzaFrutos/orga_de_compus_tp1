#include "cache.h"

#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>

#define TAMANIO_BLOQUE 64 //(B)
#define CANTIDAD_SETS 8
#define BLOQUES_POR_SET 4
#define DIRECCIONES_POR_BLOQUE 32
#define BITS_OFFSET 6
#define BITS_INDEX 3
#define BITS_TAG 7
#define ESPACIO_DIRECCIONES 16 //(b)
#define CANTIDAD_DIRECCIONES 32768 //32KB

#define MASCARA_OFFSET 0x3f

typedef struct memoria {
	unsigned char* direcciones[CANTIDAD_DIRECCIONES];
} memoria_t;

typedef struct bloque {
	unsigned char* direcciones[DIRECCIONES_POR_BLOQUE];
	unsigned int tag;
	bool v;
	unsigned int orden;
} bloque_t;

typedef struct set {
	bloque_t* bloques[BLOQUES_POR_SET];
	int latest;
	unsigned int oldest;
} set_t;

typedef struct cache {
	set_t* sets[CANTIDAD_SETS];
	unsigned int total_accesos;
	unsigned int misses;
} cache_t;

//memorias

memoria_t* memoria;

cache_t* cache;

//Post: La memoria principal simulada queda 
//inicializada en 0, los bloques de caché como 
//inválidos y la tasa de misses en 0.
void init(){

	memoria = calloc(1, sizeof(memoria_t));
	for (unsigned int i=0; i<CANTIDAD_DIRECCIONES; ++i){
		memoria->direcciones[i] = calloc(1, sizeof(unsigned char));
	}

	cache = calloc(1, sizeof(cache_t));
	for (unsigned int i=0; i<CANTIDAD_SETS; ++i){
		cache->sets[i] = calloc(1, sizeof(set_t));
		cache->sets[i]->oldest = 0;
		cache->sets[i]->latest = -1;
		for (unsigned int j=0; j<BLOQUES_POR_SET; ++j){
			cache->sets[i]->bloques[j] = calloc(1, sizeof(bloque_t));
			for (int k=0; k<DIRECCIONES_POR_BLOQUE; k++)
				cache->sets[i]->bloques[j]->direcciones[k] = calloc(1, sizeof(unsigned char));
			cache->sets[i]->bloques[j]->v = false;
			cache->sets[i]->bloques[j]->orden = 0;
		}
	}
	cache->total_accesos = 0;
	cache->misses = 0;
}

//Pre: recibe una address como unsigned int
//Post: devuelve el offset del byte del bloque de memoria al que 
//mapea la dirección address.
unsigned int get_offset(unsigned int address){
	unsigned int offset = 0;
	offset = address & 0x1f;
	printf("off: %i\n", offset);

	return offset;
}

//Pre: recibe una address como unsigned int
//Post: devuelve el conjunto de caché al que
//mapea la dirección address.
unsigned int find_set(unsigned int address){
	unsigned int set = 0;
	set = address & 0xe0;
	set = set >> 5;
	printf("set: %i\n", set);
	return set;
}

unsigned int get_tag(unsigned int address){
	unsigned int tag = 0;
	tag = address & 0xff00;
	tag = tag >> 8;
	printf("tag: %i\n", tag);

	return tag;
}

//Pre: Recibe setnum como unsigned int.
//Post: devuelve la vía en la que esta el bloque mas
//"viejo" dentro de un conjunto, utilizando el campo
//correspondiente de los metadatos de los bloques del conjunto.
unsigned int select_oldest(unsigned int setnum){
	unsigned int way = 0;
	unsigned int orden_mas_viejo = 10;
	
	for (int i=0; i<BLOQUES_POR_SET; ++i){
		if (cache->sets[setnum]->bloques[i]->orden < orden_mas_viejo){
			way = i;
		}
	}

	return way;
}

//Pre: Recibe un blocknum, la vía y el conjunto.
//Lee el bloque blocknum de memoria y lo guarda en el conjunto y 
//vía indicados en la memoria caché.
//Post: Deja a la caché en el estado indicado.
void read_tocache(unsigned int blocknum, unsigned int way, unsigned int set){
	printf("Ad: %u, way: %u, set: %u\n", blocknum, way, set);

	bloque_t* bloque = calloc(1, sizeof(bloque_t));
	for (int i=0; i<DIRECCIONES_POR_BLOQUE; ++i){
		bloque->direcciones[i] = calloc(1, sizeof(unsigned char));
		*bloque->direcciones[i] = *memoria->direcciones[blocknum + i];
	}
	bloque->v = true;
	bloque->orden = (cache->sets[set]->latest + 1) % 4;
	bloque->tag = get_tag(blocknum);
	printf("tag %u\n", bloque->tag);

	cache->sets[set]->bloques[way] = bloque;
	cache->sets[set]->latest = way;
}

/*
//Pre:
//Post:
void write_tocache(unsigned int address, unsigned char){

}*/

bool is_in_cache(unsigned int address){
	//unsigned int offset = get_offset(address);
	unsigned int idx = find_set(address);
	unsigned int tag = get_tag(address);
	int i = 0;
	while (i<BLOQUES_POR_SET){
		if (cache->sets[idx]->bloques[i]->v){
			unsigned int other_tag = cache->sets[idx]->bloques[i]->tag;
			if (tag == other_tag){
				return true;
			}
		}
		++i;
	}

	return false;
}

bool set_is_full(unsigned int set){
	for (int i=0; i<BLOQUES_POR_SET; ++i){
		if (!cache->sets[set]->bloques[i]->v)
			return false;
	}
	return true;
}

//Pre: Recibe una dirección.
//Busca el valor del byte correspondiente a la posición 
//address en la caché. Si no se encuentra carga el bloque.
//Post: Retorna el valor del byte almacenado en la 
//dirección indicada.
unsigned char read_byte(unsigned int address){
	unsigned int offset = get_offset(address);
	unsigned int idx = find_set(address);
	unsigned int tag = get_tag(address);
	bool found = false;
	int i = 0;
	while (i<BLOQUES_POR_SET && !found){
		if (cache->sets[idx]->bloques[i]->v){
			unsigned int other_tag = cache->sets[idx]->bloques[i]->tag;
			if (tag == other_tag){
				printf("Encontre\n");
				found = true;
				cache->total_accesos ++;
				return *cache->sets[idx]->bloques[i]->direcciones[offset];
			}
		}
		++i;
	}
	cache->total_accesos ++;
	if (!found)
		cache->misses ++;
	unsigned int way;
	if (set_is_full(idx)){
		way = cache->sets[idx]->oldest;
	} else {
		way = cache->sets[idx]->latest + 1;
	}
	
	read_tocache(address, way, idx);

	return *cache->sets[idx]->bloques[way]->direcciones[offset];
}

//Pre: Recibe una dirección y un valor.
//Escribe el valor value en la posición address de memoria,
//y en la posición correcta del bloque que corresponde a address,
//si el bloque se encuentra en la caché. Si no se encuentra, 
//debe escribir el valor solamente en la memoria.
void write_byte(unsigned int address, unsigned char value){
	unsigned int offset = get_offset(address);
	unsigned int idx = find_set(address);
	unsigned int tag = get_tag(address);
	int i = 0;
	bool found = false;
	while (i<BLOQUES_POR_SET && !found){
		if (cache->sets[idx]->bloques[i]->v){
			unsigned int other_tag = cache->sets[idx]->bloques[i]->tag;
			if (tag == other_tag){
				found = true;
				*cache->sets[idx]->bloques[i]->direcciones[offset] = value;
			}
		}
		++i;
	}
	cache->total_accesos ++;
	if (!found)
		cache->misses ++;
	*memoria->direcciones[address] = value;
}

//Post: devuelve el porcentaje de misses desde que se inicializó la caché.
float get_miss_rate(){
	float miss_rate = cache->misses / cache->total_accesos;
	return miss_rate;
}

void print_cache(){
	for (int i=0; i<8; ++i){
		printf("set %i\n", i);
		for (int j=0; j<4; ++j){
			printf("Bloque %i\n", j);
			printf("t: %u|v: %i|o: %u ", cache->sets[i]->bloques[j]->tag, 
				                         cache->sets[i]->bloques[j]->v,
				                         cache->sets[i]->bloques[j]->orden);
			for (int k=0; k<32; ++k){
				printf("|%i|", *cache->sets[i]->bloques[j]->direcciones[k]);
			}
			printf("\n");
		}
		printf("\n\n");
	}
}

void print_memoria(){
	for (int i=0; i<CANTIDAD_DIRECCIONES; ++i){
		printf("|%i|", *memoria->direcciones[i]);
	}
	printf("\n\n");
}


