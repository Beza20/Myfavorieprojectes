#include <stdio.h>
#include <stdlib.h>
#include "pos.h"
#include "board.h"
#include "logic.h"

void evidence_make_pos()
{
    pos new_pos = make_pos(12,11);
    pos pos_new = make_pos(5,5);
    printf("testing make_pos\n");
    printf("-expecting- pos(12,11): pos(%u,%u)\n", new_pos.r, new_pos.c);
    printf("-expecting- pos(5,5): pos(%u,%u)\n", pos_new.r, pos_new.c);
}
void evidence_game_outcome()
{
    game* gamen = new_game(3,2,8,13,BITS);
    pos one_pos = make_pos(4,7);
    pos two_pos = make_pos(4,6);
    pos three_pos = make_pos(5,7);
    pos four_pos = make_pos(5,6);
    pos five_pos = make_pos(12,0);
    pos six_pos = make_pos(11,0);
    pos seven_pos = make_pos(12,1);
    pos eight_pos = make_pos(11,1);
    board_set(gamen->b,one_pos,WHITE);
    board_set(gamen->b,two_pos,WHITE);
    board_set(gamen->b,three_pos,WHITE);
    drop_stick(gamen,5,0);
    printf("this is a board that has a few white cells and one horizontal stick played\n");
    board_show(gamen->b);
    printf("expecting- IN_PROGRESS: ");
    game_outcome(gamen);
    board_set(gamen->b,four_pos,WHITE);
    printf("this is a board that has a 2 by 2 white square and one horizontal stick played\n");
    board_show(gamen->b);
    printf("expecting- WHITE_WIN: ");
    game_outcome(gamen);
    board_set(gamen->b,five_pos,BLACK);
    board_set(gamen->b,six_pos,BLACK);
    board_set(gamen->b,seven_pos,BLACK);
    board_set(gamen->b,eight_pos,BLACK);
    printf("this is a board that has a 2 squares one white and one black and a stick played\n");
    board_show(gamen->b);
    printf("expecting- DRAW: ");
    game_outcome(gamen);
}

int main(int argc, char *argv[])
{
    evidence_make_pos();
    printf("this is an empty board 13 rows by 12 columns\n");
    board* new_board = board_new(12,13,BITS);
    board_show(new_board);
    board* big_board = board_new(65,50,BITS);
    printf("this is an empty board 50 rows with 65 columns\n");
    board_show(big_board);
    printf("4th row 5th column 8th column set to black and 10th row 8th column,7th row 2nd column, 12th row, 1st column set to white\n");
    pos pos_one = make_pos(4,5);
    pos pos_two = make_pos(4,8);
    pos pos_three = make_pos(10,8);
    pos pos_four = make_pos(7,2);
    pos pos_five = make_pos(12,0);
    board_set(new_board,pos_one,BLACK);
    board_set(new_board,pos_two,BLACK);
    board_set(new_board,pos_three,WHITE);
    board_set(new_board,pos_four,WHITE);
    board_set(new_board,pos_five,WHITE);
    board_show(new_board);
    printf("this is a board that is retrieved from the game struct with a width of 15 and height of 11\n");
    game* ngame = new_game(3,2,15,11,BITS);
    board_show(ngame->b);
    printf("this is a board that has 3 horizontal sticks and 2 vertical  sticks played\n");
    drop_stick(ngame,0,1);
    drop_stick(ngame,0,0);
    drop_stick(ngame,2,0);
    drop_stick(ngame,0,0);
    drop_stick(ngame,3,1);
    board_show(ngame->b);
    printf("this is the broken down board\n");
    breakdown(ngame);
    board_show(ngame->b);
    printf("this is more example for breakdown\n");
    board_set(ngame->b,pos_one,BLACK);
    board_set(ngame->b,pos_two,BLACK);
    board_set(ngame->b,pos_three,WHITE);
    breakdown(ngame);
    board_show(ngame->b);
    printf("checking_square- expecting 1: %d\n", check_square(ngame,10,0));
    printf("checking_vertical_spaces- expecting 1: %d\n", check_vertical_empty_spaces(ngame));
    printf("checking_horizontal_spaces - expecting 1: %d\n", check_horizontal_empty_spaces(ngame));
    printf("checkig_can_breakdown- expecting 1: %d\n", can_breakdown(ngame));
    printf("checking_game_outcme- expecting BLACK_WIN: ");
    game_outcome(ngame);
    evidence_game_outcome();
    return 0;
}
