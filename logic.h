#ifndef LOGIC_H
#define LOGIC_H

#include "board.h"


enum turn {
    BLACK_NEXT,
    WHITE_NEXT
};

typedef enum turn turn;


enum outcome {
    BLACK_WIN,
    WHITE_WIN,
    DRAW,
    IN_PROGRESS
};

typedef enum outcome outcome;


struct game {
    unsigned int stick, square;
    board* b;
    turn next;
};

typedef struct game game;

/*this function outputs a pointer to the game struct using malloc*/
game* new_game(unsigned int stick, unsigned int square, unsigned int width,
               unsigned int height, enum type type);

/*this function frees the aboved malloced regions of memory*/
void game_free(game* g);

/*this function returns an integer which indicates whether or not a stick can
be palyed in the current game status or not and then plays a stick if it can
and returns a truth value if so and not otherwise */
int drop_stick(game* g, unsigned int col, int vertical);

/*this function breaksdown all the sticks playing as if they are finally adhering to
the pull of gravity */
void breakdown(game* g);

/* this function performs a simple function where it checks if a cell is within
 a square as specified by the game struct*/
int check_square(game* g, unsigned int i, unsigned int j);

/*this functioin checks if there are empty spaces enough to hold a stick
in a column and returns true as soon as it finds them*/
int check_vertical_empty_spaces(game* g);

/* this function checks if the top row has space for a single stick to
be dropped horizontally. there is no need to check more rows*/
int check_horizontal_empty_spaces(game* g);

/* this function checks if the board is to broken down more sticks can
be played but it also returns true if there are empty spaces generally */
int can_breakdown (game* g);

/* this function indicates the outcome of the game whether either player won or if both did
or if it's still in progress */
outcome game_outcome(game* g);

#endif /* LOGIC_H */
