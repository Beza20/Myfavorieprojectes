#include <stdlib.h>
#include <stdio.h>
#include "board.h"

board* board_new(unsigned int width, unsigned int height, enum type type)
{
    board* new_board = (board*)malloc(sizeof(board));
    new_board->width = width;
    new_board->height = height;
    new_board->type = type;
    if (type == MATRIX)
    {
        cell** board_rep = (cell**)malloc(height*(sizeof(cell*)));
        for (unsigned int i = 0; i < height; i++)
        {
             board_rep[i] = (cell*)malloc(width*(sizeof(cell)));

            for (unsigned int j = 0; j < width; j++)
            {
                board_rep[i][j] = EMPTY;
            }
        }
        new_board->u.matrix = board_rep;
    }
    else
    {
        unsigned int size = (width*height)/16;
        if ((width*height%16) > 0)
        {
            size++;
        }
        unsigned int* bit_board = (unsigned int*)malloc(size*(sizeof(unsigned int)));
        for (unsigned int i = 0; i < size; i++)
        {
            bit_board[i] = 0;
        }
        new_board->u.bits = bit_board;
    }
    return new_board;
}
void board_free(board* b)
{
    if (b->type == MATRIX)
    {
        free(b->u.matrix);
    }
    else
    {
        free(b->u.bits);
    }
    free(b);
}

void board_show(board* b)
{
    for (unsigned int i = 0; i < ((b->height) + 2); i++)
    {
        for (unsigned int j = 0; j < ((b->width) + 2); j++)
        {
            if (((j < 2) && (i == 0)) || (i == 1) || ((j == 1)))
            {
                printf(" ");
            }
            else if((i == 0) && (j >= 2) && (j < 12))
            {
                printf("%u", (j-2));
            }
            else if ((i == 0) && (j >= 12) && (j < 38))
            {
                printf("%c",(j-2)+55);
            }
            else if ((i == 0) && (j >= 38) && (j < 64))
            {
                printf("%c", (j-2)+61);
            }
            else if (((i == 0) && (j >= 64)) || ((j == 0) && (i >= 64)))
            {
                printf("?");
            }
            else if ((i >= 2) && (i < 12) && (j == 0))
            {
                printf("%u",(i-2));
            }
            else if((j == 0) && (i >= 12) && (i < 38))
            {
                printf("%c",(i-2)+55);
            }
            else if ((j == 0)&& (i >= 38) && (i < 64))
            {
                printf("%c", (i-2)+61);
            }
            else
            {
                cell cell = board_get(b,make_pos((i - 2),(j-2)));
                if (cell == EMPTY)
                {
                    printf(".");
                }
                else if (cell == BLACK)
                {
                    printf("*");
                }
                else
                {
                    printf("o");
                }
            }
        }
        printf("\n");
    }
}
cell retrieve(unsigned int num, unsigned int p)
{
    return((1 << 2) - 1) & (num >> (p*2));
}
cell board_get(board* b, pos p)
{
    if ((p.r < b->height) && (p.c < b->width))
    {

        if (b->type == MATRIX)
        {

            return b->u.matrix[p.r][p.c];

        }
        else if (b->type == BITS)
        {
            unsigned int bit_index = (p.r*b->width)+p.c;
            unsigned int arr_index = bit_index/16;
            unsigned int arr_rdex = bit_index%16;
            cell bits = retrieve(b->u.bits[arr_index],arr_rdex++);
            return bits;
        }
    }
    else
    {
        fprintf(stderr, "cell not available\n");
        exit(1);
    }
}
void board_set(board* b, pos p, cell c)
{
    if ((p.r < b->height) && (p.c < b->width))
    {
        if (b->type == MATRIX)
        {
            b->u.matrix[p.r][p.c] = c;
            return;
        }
        else
        {
            unsigned int bit_index = (p.r*b->width)+p.c;
            unsigned int arr_index = bit_index/16;
            unsigned int arr_rdex = bit_index%16;
            unsigned int mask = ~(3<<(arr_rdex * 2));
            b->u.bits[arr_index] = (mask & b->u.bits[arr_index]) |
            ((unsigned int)c<<(arr_rdex * 2));
            return;
        }
    }
    else
    {
        fprintf(stderr, "cell not available\n");
        exit(1);
    }
}
