 #!/bin/bash

yacc -d -Wcounterexamples -Wother -Wconflicts-sr 1905054_parser.y
echo 'Generated the parser C file as well the header file'
flex 1905054_scanner.l
echo 'Generated the scanner C file'
g++ -w -g lex.yy.c y.tab.c -o out
echo 'Linked lex.yy.c and y.tab.c files, now running'
./out test1.c