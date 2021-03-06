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

bool is_address_valid(unsigned int address){
	return (address < CANTIDAD_DIRECCIONES);
}

bool is_flush_command(char* command){
	return (strstr(command, FLUSH));
}

bool is_r_command(char* command){
	return (strstr(command, R));
}

bool is_w_command(char* command){
	return (strstr(command, W));
}

bool is_mr_command(char* command){
    return (strstr(command, MR));
}

void parse_w_command(char* command, unsigned int *address, unsigned char *value){
	unsigned int n = 0;
	sscanf(command, "%*s %u, %u", address, &n);
	*value = n;
}

void parse_r_command(char* command, unsigned int *address){
	sscanf(command, "%*s %u", address);
}

int main(int argc, char* argv[]){
	init();

	if (argc < 2)
		printf("Falta el nombre del archivo.\n");

	FILE* file;
	file = fopen(argv[1], "r");        
	if (!file) {
		perror("Error al abrir el archivo."); 
		exit (1);
	}
	
	char command[MAX_LEN];
	while (!feof(file)) {
		if (fgets(command, MAX_LEN, file)) {
			printf("%s\n", command);
			if (is_flush_command(command)) {
				init();
			} else if (is_r_command(command)) {
				unsigned int address;
				parse_r_command(command, &address);
				if (is_address_valid(address)) {
					unsigned char value = read_byte(address);
					printf("Value: %i\n", value);
					print_cache();
				} else {
					perror("Comando invalido.\n");
				}
			} else if (is_w_command(command)) {
				unsigned int address;
				unsigned char value;
				parse_w_command(command, &address, &value);
				if (is_address_valid(address)) {
					write_byte(address, value);
					print_cache();
					print_memoria();
				} else {
					perror("Comando invalido.\n");
				}				
			} else if (is_mr_command(command)) {
                printf("Miss rate: %f\n", get_miss_rate());
            } else {
                perror("Comando invalido.\n");
            }
		}
	}
	print_cache();
//	print_memoria();
	free_resources();
	fclose(file);
	return 0;
}
