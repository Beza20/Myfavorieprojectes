play: pos.h pos.c board.h board.c logic.h logic.c play.c
	clang -Wall -g -O0 -o play pos.c board.c logic.c play.c
