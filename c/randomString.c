#include <stdlib.h>

char* rand_str(size_t length) ***REMOVED***
    char charset[] = "0123456789"
                     "abcdefghijklmnopqrstuvwxyz"
                     "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

    char *dest = (char *)malloc(length + 1);
    if (dest == NULL) ***REMOVED***
        return NULL; // Allocation failed
    ***REMOVED***

    for (size_t i = 0; i < length; i++) ***REMOVED***
        size_t index = (double)rand() / RAND_MAX * (sizeof charset - 1);
        dest[i] = charset[index];
    ***REMOVED***
    dest[length] = '\0';

    return dest;
***REMOVED***