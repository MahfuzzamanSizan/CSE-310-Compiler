%option noyywrap yylineno
%x CHAR_STATE
%x STRING_STATE
%x SINGLE_LINE_COMMENT_STATE
%x MULTI_LINE_COMMENT_STATE



%{
#include<iostream>
#include<bits/stdc++.h>
#include<string>
#include<fstream>
#include "1905054_symboltable.h"

using namespace std;

int temp_Line;
int string_Start_Line;
int line_Counter=1;
int error_Counter=0;

ofstream log_Out_File;
ofstream token_Out_File;

string character_Literal;
string lexeme;
string str;

symboltable sym_obj(10);

map<char, string> escape_Character={
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



void printLog(string tokenName, string lexeme, bool multiline=false){
	int line_no = multiline ? string_Start_Line : line_Counter;
	log_Out_File << "Line# " << line_no << ": Token <" <<  tokenName << "> Lexeme " << lexeme << " found" ;
	
	if(tokenName == "STRING" || tokenName == "CONST_CHAR") log_Out_File << " --> <" << tokenName << ", " << str << ">";
	log_Out_File << endl << endl;	
}

void printError(string errorName, string lexeme, bool multiline=false){

	error_Counter++;
	int line_no = multiline ? string_Start_Line : line_Counter;
	log_Out_File << "Error at line no " << line_no << ": " << errorName << " " << lexeme << endl << endl;
}

void token_print(string token, string lexeme){
    token_Out_File << "<" << token << ", " << lexeme << ">" << endl;
}

void log_print(int line, string token, string lexeme, bool new_line=true){
    cout << "Line# " << line << ": Token <" << token << "> Lexeme " << lexeme << " found";
    if(new_line)
    cout << endl;
}

void error_print(string errorName, string lexeme, bool multiline=false){

	error_Counter++;
	int line_no = multiline ? string_Start_Line : line_Counter;
	log_Out_File<< "Error at line no " << line_no << ": " << errorName << " " << lexeme << endl;
}


int count_line(string str){
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


void add_keyword(string keyword, string token){
    log_print(yylineno,token,keyword);
    token_Out_File << "<" << token << ", "  << keyword <<">" << endl;
}


void add_operator(string operator_, string token){
    log_print(yylineno, token, operator_);
    token_print(token, operator_);
}

void add_punctuator(string punctuator, string token){
    log_print(yylineno, token, punctuator);
    token_print(token, punctuator);
}

void add_id(string id, string token){
    log_print(yylineno,token, id);

    token_print(token, id);

    if(sym_obj.insert_symbol(id, token))
    {
        sym_obj.print_all_scope_table();
    }
}

void add_constant_number(string number, string token){
    log_print(yylineno, token, number);
    token_print(token, number);

}

void add_constant_escape_char(string escapeCharacter,string token ){
    log_print(yylineno, token, escapeCharacter, false);
    string str = escape_Character[escapeCharacter[2]];
    //cout << " --> " << "<" << token << ", " << str << "> " << endl;
    cout << endl;
    token_print(token, str);
}

void add_constant_char(string character, string token){
    log_print(yylineno, token, character, false);
    string str= "";
    str+=character[1];
    //cout << " --> " << "<" << token << ", " << str << "> " << endl;
    cout << endl;
    token_print(token, str);
}


void add_string(string str, string token){
    int lineCount = 0;
    
    string str1="";
    for(int i=0; i< str.length(); i++){
        if(str[i]=='\n')
        {
            lineCount++;
        }
        if(str[i]=='\\')
        {
            str1+=escape_Character[str[i+1]];
            i++;
        }
        else
        {
            str1+=str[i];
        }
        
    }

    log_print(yylineno-lineCount, token, str, false);

    cout << " --> " << "<" << token << ", " << str1 << ">" << endl;

    token_print(token, str1);

}

void add_comment(string comment){
    log_print(yylineno-count_line(comment), "Comment", comment);
}

void error_message(int line, string symbol, string errorMessage){
    cout << "Error at line# " << line << ": " << errorMessage << " " << symbol << endl;
    error_Counter++;}

%}


DIGIT [0-9]
LETTER [a-zA-Z]
LETTER_ [a-zA-Z_]
CONST_FLOAT {DIGIT}*(\.{DIGIT}+)?{EXPONENT}?
CONST_CHAR \'[^\\\n\r]\'
CONST_ESCAPE_CHAR \'\\[nt\\'afrbv0]\'
IDENTIFIER [a-zA-Z_][a-zA-Z0-9_]*
ESCAPE_CHAR [nt\\'afrbv0]
EXPONENT [Ee][+-]?{DIGIT}+
NEWLINE (\r)?\n

SINGLELINE_COMMENT [/][/](([\\][\n])|(.))*
MULTILINE_COMMENT (\/\*)([^\*]|\*[^\/])*(\*\/)
UNFINISHED_COMMENT ([/][*])([^\*]|\*[^\/])*

TOO_MANY_DECIMAL_POINTS {DIGIT}*(\.{DIGIT}*)+(\.{DIGIT}*)+{EXPONENT}?
MULTI_CHAR_CONST \'.[^\'\r\n]+\'
UNTERMINATED_CHAR \'(.|\\\')?[^\'\r\n]*
ILL_FORMAT_NUMBER {DIGIT}*[Ee][+-]?{DIGIT}*(\.{DIGIT}*)+
INVALID_SUFFIX_PREFIX {CONST_FLOAT}+{IDENTIFIER}+






%%

[ \t\v]+ {}
{NEWLINE} {}

if {add_keyword("if","IF");}
else {add_keyword("else","ELSE");}
for {add_keyword("for","FOR");}
float {add_keyword("float","FLOAT");}
double {add_keyword("double","DOUBLE");}
void {add_keyword("void","VOID");}
return {add_keyword("return","RETURN");}
switch {add_keyword("switch","SWITCH");}
while {add_keyword("while","WHILE");}
do {add_keyword("do","DO");}
break {add_keyword("break","BREAK");}
int {add_keyword("int","INT");}
char {add_keyword("char","CHAR");}
case {add_keyword("case","CASE");}
default {add_keyword("default","DEFAULT");}
continue {add_keyword("continue","CONTINUE");}


{DIGIT}+ {
    add_constant_number(yytext, "CONST_INT");
}

{CONST_ESCAPE_CHAR} {
    add_constant_escape_char(yytext, "CONST_CHAR");
}

{CONST_FLOAT} {
    add_constant_number(yytext, "CONST_FLOAT");
}

{CONST_CHAR} {
    add_constant_char(yytext, "CONST_CHAR");
}

\<|"<="|\>|">="|"=="|"!=" { add_operator(yytext, "RELOP");}
\= {add_operator(yytext,"ASSIGNOP");}
"&&"|"||" {add_operator(yytext, "LOGICOP");}
\! {add_operator(yytext, "NOT");}
[+-] {add_operator(yytext, "ADDOP");}
[*/%] {add_operator(yytext, "MULOP");}
"++"|"--" {add_operator(yytext, "INCOP");}
\( {add_punctuator(yytext, "LPAREN");}
\) {add_punctuator(yytext, "RPAREN");}
\{ {
    add_punctuator(yytext, "LCURL");
    sym_obj.enter_scope();
}
\} {
    add_punctuator(yytext,"RCURL");
    sym_obj.exit_scope();
}
\[ {add_punctuator(yytext, "LSQUARE");}
\] {add_punctuator(yytext, "RSQUARE");}
\, {add_punctuator(yytext, "COMMA");}
\; {add_punctuator(yytext, "SEMICOLON");}

{IDENTIFIER} {add_id(yytext,"ID");}



{SINGLELINE_COMMENT}  {	
		for(int i = 0; i < strlen(yytext); i++){
			if(yytext[i] == '\n'){
				line_Counter++;
			}
		}	
		printLog("COMMENT", lexeme, true);
}

{UNFINISHED_COMMENT} {
		printError("Unterminated Comment", yytext);
		for(int i = 0; i < yyleng; i++){
			if(yytext[i] == '\n'){
				line_Counter++;
			}
		}
}

{MULTILINE_COMMENT}  {
		printLog("COMMENT", lexeme, true);
		for(int i = 0; i < strlen(yytext); i++){
			if(yytext[i] == '\n'){
				line_Counter++;
			}
		}		
}





(\")(.|\\.|\\{NEWLINE})*(\") {
    //cout << "Line# : "<< yylineno << endl;
    add_string(yytext, "STRING");
}

(\")(.|\\.|\\{NEWLINE})* {
     //cout << "Line# : "<< yylineno << endl;

     int lineCount=0;
     string str = yytext;
     for(int i=0;i< str.length();i++)
     {
        if(str[i]=='\n')
        lineCount++;
     }

     error_message(yylineno-lineCount,yytext, "UNFINISHED_STRING");
     //error_message(yylineno-count_line(str),str, "UNFINISHED_STRING");

}


("//")(.|(\\{NEWLINE}))* {
    add_comment(yytext);
}

("/*")(.|{NEWLINE})*("*/") {
    add_comment(yytext);
}

("/*")(.|{NEWLINE})* {
    string str= yytext;
    error_message(yylineno-count_line(str),str, "UNFINISHED_COMMENT");
    sym_obj.print_all_scope_table();
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
    //sym_obj.print_all_scope_table();
    cout << "Total lines: " << yylineno << endl;
    cout << "Total errors: " << error_Counter << endl;
    return 0;
}

. {error_message(yylineno,yytext,"UNRECOGNIZED_CHAR");}

%%

int main(int argc, char *argv[])
{
    if(argc!=2)
    {
        cout << "Please provide input file name and try again." << endl;
        return 0;
    }

    FILE *fin = freopen(argv[1],"r",stdin);

    if(fin == nullptr)
    {
        cout << "Can't open specified file." << endl;
        return 0;
    }

    token_Out_File.open("1905054_token.txt");
    freopen("1905054_log.txt", "w", stdout);

    yyin = fin;
    yylineno = 1;

    yylex();
    fclose(yyin);

    return 0;
}





