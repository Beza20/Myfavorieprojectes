#include <stdio.h>
#include <stdlib.h>
#include "logic.h"

game* new_game(unsigned int stick, unsigned int square, unsigned int width,
               unsigned int height, enum type type)
               {
                   game* n_game = (game*)malloc(sizeof(game));
                   n_game->stick = stick;
                   n_game->square = square;
                   n_game->b = board_new(width,height,type);
                   n_game->next = BLACK_NEXT;
                   return n_game;
               }
void game_free(game* g)
{
    board_free(g->b);
    free(g);
    return;
}
/*the following function finds the lowest member in an array of unsigned ints*/
unsigned int minm (unsigned int* empty_cells, int alen)
{
    unsigned int min = empty_cells[0];
    for (unsigned int i = 0; i < alen; i++)
    {
        if (empty_cells[i] <= min)
        {
            min = empty_cells[i];
        }
    }
    return min;
}

/*it was a personal preference to put all of the code for this function
under it. I thought it was nice that it can be understood so simply.
I shall try to explain as it goes.*/
int drop_stick(game* g, unsigned int col, int vertical)
{
    //its's counting empty spaces so that the number can be used later to find
    //where to start when changing cell to drop stick
    unsigned int count = 0;
    for (unsigned int i = 0;
            (i < g->b->height) && ((board_get(g->b,(make_pos(i,col))) == EMPTY));
             i++)
    {
        count++;
    }
    if (vertical)
    {
        if ((count - g->stick) >= 0)
        {
            if (g->next == BLACK_NEXT)
            {
                count--;//to match rows
                for (unsigned int j = 0; j < g->stick; j++)
                {
                    board_set(g->b,(make_pos(count,col)),BLACK);
                    count--;
                }
                return 1;
            }
            else
            {
                count--;
                for (unsigned int k = 0; k < g->stick; k++)
                {
                    board_set(g->b,(make_pos(count,col)),WHITE);
                    count--;
                }
                return 1;
            }
        }
        else
        {
            return 0;
        }
    }
    else//when horizontal
    {
        if ((g->stick) + col <= (g->b->width))
        {
            //creating an array so that i can see how many empty cells each
            //column the stick is about to rest on has at the top and find the
            //one with least number
            unsigned int* empty_cells = (unsigned int*)malloc(sizeof(unsigned int) * g->stick);
            unsigned int l = 0;
            unsigned int temp_col = col;
            do
            {
                unsigned int count_h = 0;
                for (unsigned int i = 0;
                        (i < g->b->height)&& ((board_get(g->b,(make_pos(i,col))) == EMPTY));
                        i++)
                {
                    count_h++;
                }
                empty_cells[l] = count_h;
                l++;
                col++;
            }
            while (l < g->stick);
            unsigned int min = minm(empty_cells,g->stick);
            if (min > 0)
            {
                if (g->next == BLACK_NEXT)
                {
                    for (unsigned int j = 0; j < g->stick; j++)
                    {
                        board_set(g->b,(make_pos((min-1),temp_col)),BLACK);
                        temp_col++;
                    }
                    return 1;
                }
                else
                {
                    for (unsigned int j = 0; j < g->stick; j++)
                    {
                        board_set(g->b,(make_pos((min-1),temp_col)),WHITE);
                        temp_col++;
                    }
                    return 1;
                }
            }
            else
            {
                return 0;
            }
            free(empty_cells);
        }
        else
        {
            return 0;
        }
    }
}

void breakdown(game* g)
{
    for (unsigned int i = 0; i < g->b->width; i++)
    {
        //cell* temp_cells[g->b->height];
        cell* temp_cells = (cell*)malloc(sizeof(cell) * g->b->height);
        unsigned int count = 0;
        for (unsigned int j = 0; j < g->b->height; j++)
        {
            cell cell = board_get((g->b),(make_pos((g->b->height)-1-j,i)));
            if (cell == EMPTY)
            {
                continue;
            }
            else
            {
                temp_cells[count] = cell;
                count++;
                board_set(g->b,(make_pos(((g->b->height)-1-j),i)),EMPTY);
            }
        }
        for (unsigned int k = 0; k < count; k++)
        {
            pos position = make_pos(((g->b->height)-1-k),i);
            board_set(g->b,position,temp_cells[k]);

        }
        free(temp_cells);
    }
}

/* this function performs a simple function where it checks if a cell is within
 a square as specified by the game struct*/
int check_square(game* g, unsigned int i, unsigned int j)
{
    cell cell = board_get((g->b),(make_pos(i,j)));
    if (cell != EMPTY)
    {
        unsigned int count = 0;
        for(unsigned int k = 0; k < g->square; k++)
        {
            for (unsigned int l = 0; l < g->square; l++)
            {
                if (cell == (board_get((g->b),(make_pos((i - l),(j+k))))))
                {
                    count++;
                }
                else
                {
                    continue;
                }
            }
        }
        if (count == (g->square * g->square))
        {
           return 1;
        }
        else
        {
            return 0;
        }
    }
    else
    {
        return 0;
    }
}

/*this functioin checks if there are empty spaces enough to hold a stick
in a column and returns true as soon as it finds them*/
int check_vertical_empty_spaces(game* g)
{
    for (unsigned int i = 0; i < g->b->width; i++)
    {
        unsigned int count = 0;
        for (unsigned int j = 0; j < g->b->height; j++)
        {
            if (board_get(g->b,make_pos(j,i)) == EMPTY)
            {
                count++;
            }
            else
            {
                break;
            }
        }
        if (count >= g->stick)
        {
            return 1;
        }
        else
            continue;
    }
    return 0;
}

/* this function checks if the top row has space for a single stick to
be dropped horizontally. there is no need to check more rows*/
int check_horizontal_empty_spaces(game* g)
{
    unsigned int count = 0;
    for (unsigned int j = 0; j <= (g->b->width - g->stick); j++)
    {
        for (unsigned int k = 0; k < g->stick; k++)
        {
            if (board_get(g->b,(make_pos(0,(j+k)))) == EMPTY)
            {
                continue;
            }
            else
            {
                count++;
                break;
            }
        }

    }
    if (count >= ((g->b->width - g->stick) + 1))
    {
        return 0;
    }
    else
    {
        return 1;
    }
}

/* this function checks if the board is to broken down more sticks can
be played but it also returns true if there are empty spaces generally */
int can_breakdown (game* g)
{
    for (unsigned int i = 0; i < g->b->width; i++)
    {
        unsigned int count = 0;
        for (unsigned int j = 0; j < g->b->height; j++)
        {
           if (board_get(g->b,(make_pos(j,i))) == EMPTY)
            {
               count++;
            }
            else
            {
                continue;
            }
        }
        if (count >= g->stick)
        {
            return 1;
        }
        else
        {
            continue;
        }
    }
    return 0;
}


outcome game_outcome(game* g)
{
    unsigned int count_b = 0;
    unsigned int count_w = 0;
    for (unsigned int i = 0; i <= (g->b->width - g->square); i++)
    {
        for (unsigned int j = (g->square - 1); j < g->b->height; j++)
        {
            if (check_square(g,j,i))
            {
                if (board_get(g->b,make_pos(j,i)) == BLACK)
                {
                    count_b++;
                }
                else
                {
                    count_w++;
                }
            }
            else
            {
                continue;
            }
        }
    }
    if ((count_b == 0) && (count_w == 0) &&
            (check_vertical_empty_spaces(g) || check_horizontal_empty_spaces(g) || can_breakdown(g)))
    {
        //printf("IN_PROGRESS\n");
        return IN_PROGRESS;
    }
    else if (count_b == count_w)
    {
        printf("DRAW\n");
        return DRAW;
    }
    else if( count_b > count_w)
    {
        printf("BLACK_WIN\n");
        return BLACK_WIN;
    }
    else
    {
        printf("WHITE_WIN\n");
        return WHITE_WIN;
    }
}




