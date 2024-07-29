#include <stdio.h>
#include <stdlib.h>
#include "randomString.h"

int main() {
    size_t length = 10;
    char *random_string = rand_str(length);
    if (random_string == NULL) {
        printf("Memory allocation failed!\n");
    }else {
        printf("Random string: %s\n", random_string);
        free(random_string);
    }
    return 0;
}