#include <stdio.h>
#include <stdlib.h>
#include "pos.h"
#include "board.h"
#include "logic.h"
#include <string.h>
/*this function basically dictates the flow of the game
where it goes through the game by checking each input made by
the players and chenges the turn once proper inputs are made*/
void playing (game* g)
{
    while(game_outcome(g) == IN_PROGRESS)
    {
        char t;
        unsigned int col;
        if (g->next == BLACK_NEXT)
        {
            printf("Black: \n");
            scanf("%c%*c", &t);
            if (t == '|')
            {
                printf("column: \n");
                scanf("%u%*c", &col);
                if (col < g->b->width)
                {

                    drop_stick(g,col,1);
                    board_show(g->b);
                    g->next = WHITE_NEXT;
                }
                else
                {
                    printf("please put available input \n");
                    g->next = BLACK_NEXT;
                }
            }
            else if (t == '-')
            {
                printf("column: \n");
                scanf("%u%*c", &col);
                if (col <= (g->b->width - g->stick))
                {
                    drop_stick(g,col,0);
                    board_show(g->b);
                    g->next = WHITE_NEXT;
                }
                else
                {
                    printf("please put available input \n");
                    g->next = BLACK_NEXT;
                }
            }
            else if (t == '!')
            {
                breakdown(g);
                board_show(g->b);
                g->next = WHITE_NEXT;
            }
            else
            {
                printf("please put the correct input \n");
                g->next = BLACK_NEXT;
            }
        }
        else
        {
            printf("White: \n");
            scanf("%c%*c", &t);
            if (t == '|')
            {
                printf("column: \n");
                scanf("%u%*c", &col);
                if (col < g->b->width)
                {
                    drop_stick(g,col,1);
                    board_show(g->b);
                    g->next = BLACK_NEXT;
                }
                else
                {
                    printf("please put available input \n");
                    g->next = WHITE_NEXT;
                }
            }
            else if (t == '-')
            {
                printf("column: \n");
                scanf("%u%*c", &col);
                if (col <= (g->b->width - g->stick))
                {
                    drop_stick(g,col,0);
                    board_show(g->b);
                    g->next = BLACK_NEXT;
                }
                else
                {
                    printf("please put available input \n");
                    g->next = WHITE_NEXT;
                }
            }
            else if (t == '!')
            {
                breakdown(g);
                board_show(g->b);
                g->next = BLACK_NEXT;
            }
            else
            {
                printf("please put the correct input \n");
                g->next = WHITE_NEXT;
            }
        }
    }
}
/*this function checks if there is a proper specification of which version
 to use by the user*/
unsigned int check (char *argv[], int argc, char* version)
{
    for (unsigned int i = 0; i < argc; i++)
    {
        if (!strcmp(argv[i],version))
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

/*this function carries out the game by reading through the inputs made in
the command line and utilize previous helper functions*/
int main(int argc, char *argv[])
{
    game* g = NULL;
    char w[] = "-w";
    char h[] = "-h";
    char k[] = "-k";
    char q[] = "-q";
    char m[] = "-m";
    char b[] = "-b";
    unsigned int stick = 1;
    unsigned int square = 1;
    unsigned int width = 1;
    unsigned int height = 1;
    if (check(argv,argc,m) ^ (check(argv,argc,b)))
    {
        for (unsigned int i = 0; i < argc; i++)
        {
            if (strcmp(argv[i],w) == 0)
            {
                width = atoi(argv[i+1]);
            }
            else if (strcmp(argv[i],h) == 0)
            {
                height = atoi(argv[i+1]);
            }
            else if (strcmp(argv[i],q) == 0)
            {
                square = atoi(argv[i+1]);
            }
            else if (strcmp(argv[i],k) == 0)
            {
                stick = atoi(argv[i+1]);
            }
            else if (strcmp(argv[i],b) == 0)
            {
                g = new_game(stick,square,width,height,BITS);
            }
            else if (strcmp(argv[i],m) == 0)
            {
                g = new_game(stick,square,width,height,MATRIX);
            }
        }
        printf("the game has started\n");
        board_show(g->b);
        playing(g);
    }
    else
    {
        fprintf(stderr, "please specify bit or matrix version you want to play\n");
        exit(1);
    }
}
