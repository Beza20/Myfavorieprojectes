#ifndef BOARD_H
#define BOARD_H

#include "pos.h"


enum cell {
    EMPTY,
    BLACK,
    WHITE
};

typedef enum cell cell;


union board_rep {
    enum cell** matrix;
    unsigned int* bits;
};

typedef union board_rep board_rep;

enum type {
    MATRIX, BITS
};


struct board {
    unsigned int width, height;
    enum type type;
    board_rep u;
};

typedef struct board board;

/*this function puts out a pointer to a board struct that contains
the width and height etc using malloc for matrix version and if it
is a bits version mallocs an array of unsigned ints with all elements
set to 0*/
board* board_new(unsigned int width, unsigned int height, enum type type);

/*this function frees the above malloced things*/
void board_free(board* b);

/*this function displays the form of the board that was made using the
board_new function and includes headers of rows and columns*/
void board_show(board* b);

/*this function retrieves a particular cell from a board and tells if
it's empty, black, or white for matrix version and pretty much does the
same thing for bits version but first calculates which unsigned int and
bit reprsentation corresponds to a cell */
cell board_get(board* b, pos p);

/*this function turns a particular cell into the type of cell inputted by the
function parameter and implements pretty much the same strategy as board get but
here manipulates bit wise operators and utilizes mask to change to 2 single
bits that are meant to be set*/
void board_set(board* b, pos p, cell c);

#endif /* BOARD_H */
