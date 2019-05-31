#include "cache.h"

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>

#define MAX_LEN 13
#define FLUSH "FLUSH"
#define R "R "
#define W "W"
#define MR "MR"

void print_cache(){
	
}

bool is_flush_command(char* command){
	if (strstr(command, FLUSH))
		return true;
	return false;
}

bool is_r_command(char* command){
	if (strstr(command, R))
		return true;
	return false;
}

bool is_w_command(char* command){
	if (strstr(command, W))
		return true;
	return false;
}

bool is_mr_command(char* command){
	if (strstr(command, MR))
		return true;
	return false;
}

//return strstr(command, MR) ? true : false

void parse_command(char* command, unsigned int *address, unsigned char *value){
	char aux[10];
	unsigned int n = 0;
	sscanf(command, "%s %u, %u", aux, address, &n);
	//printf("n:%u\n", n);
	*value = n;
	//printf("%s, %u, %i\n", aux, *address, *value);
}

int main(int argc, char* argv[]){
	init();

	if (argc < 2)
		printf("Falta el nombre del archivo.\n");

	FILE* file;
	file = fopen(argv[1], "r");        
	if (!file) {
		perror("Error al abrir el archivo"); 
		exit (1);
	}
	
	char command[MAX_LEN];
	while (!feof(file)){
		if (fgets(command, MAX_LEN, file)){
			printf("%s\n", command);
			if (is_flush_command(command)){
				init();
			} else if (is_r_command(command)){

			} else if (is_w_command(command)){
				unsigned int address;
				unsigned char value;
				parse_command(command, &address, &value);
				//printf("%u, %c\n", address, value);
				write_byte(address, value);
			} else if (is_mr_command(command)){
				float miss_rate = get_miss_rate();
				printf("Miss rate: %.3f\n", miss_rate);
			} else {
				perror("Comando invalido\n");
			}
		}
	}

	fclose(file);

	return 0;
}



/*
FLUSH
R ddddd
W ddddd, vvv
MR
El comando “FLUSH” se ejecuta llamando a la función init(). Repre-
senta el vaciado del caché.
Los comandos de la forma “R ddddd” se ejecutan llamando a la función
read byte(ddddd) e imprimiendo el resultado.
Los comandos de la forma “W ddddd, vvv” se ejecutan llamando a la
función write byte(unsigned int ddddd, char vvv) e imprimien-
do el resultado.
El comando “MR” se ejecuta llamando a la función get miss rate() e
imprimiendo el resultado.
El programa deberá chequear que las lı́neas del archivo correspondan a un
comando con argumentos dentro del rango estipulado, o de lo contrario
estar vacı́as. En caso de que una lı́nea tenga otra cosa que espacios blancos
y no tenga un comando válido, se deberá imprimir un mensaje de error
informativo.
*/