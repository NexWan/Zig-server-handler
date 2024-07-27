#include <stdio.h>
#include <stdlib.h>
#include "randomString.h"

int main() ***REMOVED***
    size_t length = 10;
    char *random_string = rand_str(length);
    if (random_string == NULL) ***REMOVED***
        printf("Memory allocation failed!\n");
    ***REMOVED***else ***REMOVED***
        printf("Random string: %s\n", random_string);
        free(random_string);
    ***REMOVED***
    return 0;
***REMOVED***