#include <stdlib.h>
#include <stdio.h>
#include "pos.h"

pos make_pos(unsigned int r, unsigned int c)
{
    pos* new_pos = (pos*)malloc(sizeof(pos));
    new_pos->r = r;
    new_pos->c = c;
    return *new_pos;
}
