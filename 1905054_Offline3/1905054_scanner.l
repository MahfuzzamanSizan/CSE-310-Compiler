%option noyywrap yylineno


%{


#include<iostream>
#include<bits/stdc++.h>
#include<string>
#include<fstream>



#include "1905054_symboltable.h"

#include "y.tab.h"




using namespace std;



int temp_Line;
int string_Start_Line;
int line_Counter=1;
int error_Counter=0;

extern ofstream log_Out_File;
ofstream token_Out_File;

string character_Literal;
string lexeme;
string str;
int line_no=1;


extern YYSTYPE yylval;
extern symboltable* sym_table;
extern int no_of_error;



symboltable sym_obj(10);

//bool multiline = false;
//int line_no = multiline ? string_Start_Line : line_Counter;

map<char, string> escape_Character=

{

{'n',"\n"},

{'t',"\t"},

{'\\',"\\"},

{'\'',"\'"},

{'a',"\a"},

{'f',"\f"},

{'r',"\r"},

{'b',"\b"},

{'v',"\v"},

{'0',"\0"},

{'\"',"\""},

};




int count_line(string str)
{

    int count = 0;


    for(int i=0; i< str.length(); i++)
    {

        if(str[i]=='\n')
        {
            count++;
        }

    }


    return count;

}




void error_message(int line, string symbol, string errorMessage){
    cout << "Error at line# " << line << ": " << errorMessage << " " << symbol << endl;
    error_Counter++;}

%}





DIGIT [0-9]


CONST_FLOAT {DIGIT}*(\.{DIGIT}+)?{EXPONENT}?


CONST_CHAR \'[^\\\n\r]\'


CONST_ESCAPE_CHAR \'\\[nt\\'afrbv0]\'


IDENTIFIER [a-zA-Z_][a-zA-Z0-9_]*


EXPONENT [Ee][+-]?{DIGIT}+


NEWLINE (\r)?\n






TOO_MANY_DECIMAL_POINTS {DIGIT}*(\.{DIGIT}*)+(\.{DIGIT}*)+{EXPONENT}?


MULTI_CHAR_CONST \'.[^\'\r\n]+\'4


UNTERMINATED_CHAR \'(.|\\\')?[^\'\r\n]*


ILL_FORMAT_NUMBER {DIGIT}*[Ee][+-]?{DIGIT}*(\.{DIGIT}*)+


INVALID_SUFFIX_PREFIX {CONST_FLOAT}+{IDENTIFIER}+






%%



[ \t\v]+ {}

{NEWLINE} {line_no++;}



"if" {
    //yylval.symbol_info = new symbolinfo(yytext, "CONST_INT");
    log_Out_File << "Line# " << line_no << ": Token <IF> Lexeme " << yytext << " found" << endl;
    return IF;}

"else" {
    log_Out_File << "Line# " << line_no << ": Token <ELSE> Lexeme " << yytext << " found" << endl ;
    return ELSE;}

"for" {
    log_Out_File << "Line# " << line_no << ": Token <FOR> Lexeme " << yytext << " found" << endl ;
    return FOR;}

"float" {
    log_Out_File << "Line# " << line_no << ": Token <FLOAT> Lexeme " << yytext << " found" << endl ;
    return FLOAT;}

"double" {
    log_Out_File << "Line# " << line_no << ": Token <DOUBLE> Lexeme " << yytext << " found" << endl ;
    return DOUBLE;}

"void" {
    log_Out_File << "Line# " << line_no << ": Token <VOID> Lexeme " << yytext << " found" << endl ;
    return VOID;}

"return" {
    log_Out_File << "Line# " << line_no << ": Token <RETURN> Lexeme " << yytext << " found" << endl ;
    return RETURN;}

"switch" {
    log_Out_File << "Line# " << line_no << ": Token <SWITCH> Lexeme " << yytext << " found" << endl ;
    return SWITCH;}

"case" {
    log_Out_File << "Line# " << line_no << ": Token <CASE> Lexeme " << yytext << " found" << endl ;
    return CASE;}

"default" {
    log_Out_File << "Line# " << line_no << ": Token <DEFAULT> Lexeme " << yytext << " found" << endl ;
    return DEFAULT;}

"while" {
    log_Out_File << "Line# " << line_no << ": Token <WHILE> Lexeme " << yytext << " found" << endl ;
    return WHILE;}

"do" {
    log_Out_File << "Line# " << line_no << ": Token <DO> Lexeme " << yytext << " found" << endl ;
    return DO;}

"break" {
    log_Out_File << "Line# " << line_no << ": Token <BREAK> Lexeme " << yytext << " found" << endl ;
    return BREAK;}

"continue" {
    log_Out_File << "Line# " << line_no << ": Token <CONTINUE> Lexeme " << yytext << " found" << endl ;
    return CONTINUE;}

"int" {
    log_Out_File << "Line# " << line_no << ": Token <INT> Lexeme " << yytext << " found" << endl ;
    return INT;}

"char" {
    log_Out_File << "Line# " << line_no << ": Token <CHAR> Lexeme " << yytext << " found" << endl ;
    return CHAR;}

"printf" {
    log_Out_File << "Line# " << line_no << ": Token <PRINTLN> Lexeme " << yytext << " found" << endl ;
    return PRINTLN;}





{DIGIT}+ {
    
    log_Out_File << "Line# " << line_no << ": Token <CONST_INT> Lexeme " << yytext << " found" << endl ;
    yylval.sym_info = new symbolinfo(yytext, "CONST_INT");

    return CONST_INT;

}

{CONST_ESCAPE_CHAR} {

    log_Out_File << "Line# " << line_no << ": Token <CONST_CHAR> Lexeme " << yytext << " found" << endl ;
    yylval.sym_info = new symbolinfo(yytext, "CONST_CHAR");

    return CONST_CHAR;

}

{CONST_FLOAT} {
    
    log_Out_File << "Line# " << line_no << ": Token <CONST_FLOAT> Lexeme " << yytext << " found" << endl ;
    yylval.sym_info = new symbolinfo(yytext, "CONST_FLOAT");

    return CONST_FLOAT;

}

{CONST_CHAR} {
    
    log_Out_File << "Line# " << line_no << ": Token <CONST_CHAR> Lexeme " << yytext << " found" << endl ;
    yylval.sym_info = new symbolinfo(yytext, "CONST_CHAR");

    return CONST_CHAR;

}





\<|"<="|\>|">="|"=="|"!=" { 

    log_Out_File << "Line# " << line_no << ": Token <RELOP> Lexeme " << yytext << " found" << endl ;
    yylval.sym_info = new symbolinfo(yytext, "RELOP");

    return RELOP;
    
}



"&&"|"||" {
    
    log_Out_File << "Line# " << line_no << ": Token <LOGICOP> Lexeme " << yytext << " found" << endl ;
    yylval.sym_info = new symbolinfo(yytext, "LOGICOP");

    return LOGICOP;

}


\= {
    log_Out_File << "Line# " << line_no << ": Token <ASSIGNOP> Lexeme " << yytext << " found" << endl ;
    return ASSIGNOP;}


\! {
    log_Out_File << "Line# " << line_no << ": Token <NOT> Lexeme " << yytext << " found" << endl ;
    return NOT;}


[+-] {

    log_Out_File << "Line# " << line_no << ": Token <ADDOP> Lexeme " << yytext << " found" << endl ;
    yylval.sym_info = new symbolinfo(yytext, "ADDOP");

    return ADDOP;

}


[*/%] {
    
    log_Out_File << "Line# " << line_no << ": Token <MULOP> Lexeme " << yytext << " found" << endl ;
    yylval.sym_info = new symbolinfo(yytext, "MULOP");

    return MULOP;

}


"++" {
    log_Out_File << "Line# " << line_no << ": Token <INCOP> Lexeme " << yytext << " found" << endl ;
    return INCOP;}


"--" {
    log_Out_File << "Line# " << line_no << ": Token <DECOP> Lexeme " << yytext << " found" << endl ;
    return DECOP;}


\( {
    log_Out_File << "Line# " << line_no << ": Token <LPAREN> Lexeme " << yytext << " found" << endl ;
    return LPAREN;}


\) {
    log_Out_File << "Line# " << line_no << ": Token <RPAREN> Lexeme " << yytext << " found" << endl ;
    return RPAREN;}


\{ {
    log_Out_File << "Line# " << line_no << ": Token <LCURL> Lexeme " << yytext << " found" << endl ;
    return LCURL;
}


\} {
    log_Out_File << "Line# " << line_no << ": Token <RCURL> Lexeme " << yytext << " found" << endl ;
    return RCURL;
}


\[ {
    log_Out_File << "Line# " << line_no << ": Token <LSQUARE> Lexeme " << yytext << " found" << endl ;
    return LSQUARE;}


\] {
    log_Out_File << "Line# " << line_no << ": Token <RSQUARE> Lexeme " << yytext << " found" << endl ;
    return RSQUARE;}


\, {
    log_Out_File << "Line# " << line_no << ": Token <COMMA> Lexeme " << yytext << " found" << endl ;
    return COMMA;}


\; {
    log_Out_File << "Line# " << line_no << ": Token <SEMICOLON> Lexeme " << yytext << " found" << endl ;
    return SEMICOLON;}





{IDENTIFIER} {
    
    log_Out_File << "Line# " << line_no << ": Token <ID> Lexeme " << yytext << " found" << endl ;
    yylval.sym_info = new symbolinfo(yytext, "ID");

    return ID;

}





(\")(.|\\.|\\{NEWLINE})*(\") {
    
    log_Out_File << "Line# " << line_no << ": Token <STRING> Lexeme " << yytext << " found" << endl ;
    return STRING;

}



(\")(.|\\.|\\{NEWLINE})* {
     

     string str = yytext;

     int lineCount=0;

     for(int i=0;i< str.length();i++)
     {
        if(str[i]=='\n')
        lineCount++;
     }

     error_message(yylineno-lineCount,yytext, "UNFINISHED_STRING");
    
}




("//")(.|(\\{NEWLINE}))* {

}



("/*")(.|{NEWLINE})*("*/") {

}



("/*")(.|{NEWLINE})* {

    string str= yytext;

    error_message(yylineno-count_line(str),str, "UNFINISHED_COMMENT");

}





{TOO_MANY_DECIMAL_POINTS} {

    error_message(yylineno,yytext,"TOO_MANY_DECIMAL_POINTS");

}



{MULTI_CHAR_CONST} {

   error_message(yylineno,yytext,"MULTICHAR_CONST_CHAR"); 

}



{ILL_FORMAT_NUMBER} {

    error_message(yylineno,yytext,"ILLFORMED NUMBER");

}


{INVALID_SUFFIX_PREFIX} {

    error_message(yylineno,yytext,"INVALID_ID_SUFFIX_NUM_PREFIX");

}




\'\' {

    error_message(yylineno,yytext,"EMPTY_CONST_CHAR");

}




{UNTERMINATED_CHAR} {

    error_message(yylineno,yytext,"UNFINISHED_CONST_CHAR");

}


    <<EOF>> {

    return 0;
}



. {error_message(yylineno,yytext,"UNRECOGNIZED_CHAR");}

%%