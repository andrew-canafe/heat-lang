all: heat

heat.tab.c heat.tab.h: heat.y
	bison -d heat.y

heat.yy.c: heat.l heat.tab.h
	flex -o heat.yy.c heat.l

heat: heat.yy.c heat.tab.c heat.tab.h
	gcc heat.yy.c heat.tab.c -lfl -o heat

clean:
	rm -v heat heat.yy.c heat.tab.c heat.tab.h
