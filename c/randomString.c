#include <stdlib.h>
#include "randomString.h"

char* rand_str(size_t length) {
    char charset[] = "0123456789"
                     "abcdefghijklmnopqrstuvwxyz"
                     "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

    char *dest = (char *)malloc(length + 1);
    if (dest == NULL) {
        return NULL; // Allocation failed
    }

    for (size_t i = 0; i < length; i++) {
        size_t index = (double)rand() / RAND_MAX * (sizeof charset - 1);
        dest[i] = charset[index];
    }
    dest[length] = '\0';

    return dest;
}