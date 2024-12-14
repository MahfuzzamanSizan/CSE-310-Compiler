%{


#include <bits/stdc++.h>
#include <iostream>
#include <string>
#include <fstream>


#include "1905054_icg.h"



using namespace std;


int yylex(void);
int yyparse(void);


extern int yylineno;
extern FILE* yyin;



int parameter_declaration_line;

ofstream log_Out_File;


vector<symbolinfo*>* function_parameter_list = nullptr;





bool global_scope = true;
bool array_index= false;

map<string,string> label_map;

int parameter_count = 0;

string while_loop;




void yyerror(const char* ch)
{

    cout << "Line# " << yylineno << ": " << ch << endl;

    error_counter++;

}




void DEBUG(string str)
{

    cout << "Debug : Line " << yylineno << " : " << str << endl << endl;

}




void Log_Error(string str, int line_no=-1)
{

    error_out_file << "Line# " << (line_no == -1 ? yylineno : line_no ) << ": " << str << endl;

    cout << "Line# " << (line_no == -1 ? yylineno : line_no ) << ": " << str << endl;

    error_counter++;


}



void Log_Rule(string rules, string codes)
{

    cout << rules << endl;

}



string Variable_Declaration_List(vector <symbolinfo*>* vector_list)
{

    string str = "";

    for(symbolinfo* sym_info : *vector_list)
    {

        if(sym_info->get_array_size() == "")
        {

            str += sym_info-> get_sym_name() + "," ;

        }

        else 
        {

            str += sym_info->get_sym_name() + "[" + sym_info->get_array_size() + "],";

        }

    }


    int length = str.length();


    if(length>0)
    {

        str = str.substr(0, length-1);

    }


    return str;

}



void Free_Sym_Info_Vector(vector <symbolinfo*>* vector_list)
{

    for(symbolinfo* sym_info : *vector_list)
    {
        delete sym_info;
    }

    delete vector_list;

}



string Function_Parameter_List(vector <symbolinfo*>* vector_list)
{

    string  str = "";

	for(symbolinfo* sym_info : *vector_list)
    {

		str += sym_info->get_data_type() + " " + sym_info->get_sym_name() + ",";
        
	}
		
        
    int length = str.length();


	if(length>0)
    {

	   str = str.substr(0, length-1);

	}


	return str;

}



string Symbol_Name_List(vector <symbolinfo*>* vector_list)
{

	string str = "";


	for(symbolinfo* sym_info : *vector_list)
    {

	    str += sym_info->get_sym_name() + ",";

	}
		
        
    int length = str.length();


	if(length>0)
    {

     	str = str.substr(0, length-1);

	}
    
    
    return str;


}




void Declare_Function_Parameter(string data_type, string sym_name, int line_no = yylineno)
{

	if(data_type == "void")
    {

		Log_Error("Function parameter can not be void");

		return;

	}



	if(sym_table.insert_symbol(sym_name, "ID"))
    {

		symbolinfo* sym_info = sym_table.look_up_func(sym_name);

	    sym_info->set_data_type(data_type);

		return;

	}


	Log_Error("Redefinition of parameter '" + sym_name + "'", line_no);


}




void Declare_Function_Parameter_List(vector <symbolinfo*>* &vector_list, int line_no = yylineno)
{
		
    if(vector_list == nullptr)
    {
			
		return;

	}
		


	for(symbolinfo* sym_info : *vector_list)
    {

	    Declare_Function_Parameter(sym_info->get_data_type(), sym_info->get_sym_name(), line_no);

	}


    vector_list = nullptr;


}





void  Declare_Function(string function_name, string  return_type, vector <symbolinfo*>* parameter_list =  nullptr,  int  line_no = yylineno)
{

	
    bool flag = sym_table.insert_symbol (function_name,"ID");

		
	symbolinfo*  sym_info =  sym_table.look_up_func(function_name);

		
	if(flag)
    {
	    sym_info->set_info_type( symbolinfo :: FUNC_DEC);

        
	    sym_info->set_return_type(return_type);

			
		if(parameter_list !=  nullptr)
            for(symbolinfo* ptr : *parameter_list)
            {
			
            sym_info->add_parameter(ptr->get_data_type(),  ptr->get_sym_name());

		    }
			
		
	}
        


    else
    
    {

		if(sym_info->get_info_type() == symbolinfo :: FUNC_DEC)
        {
				
            Log_Error("Redeclaration of " +  function_name, line_no);
				
            return;

		}

	}


}





void Define_Function (string  function_name,  string return_type, int line_no = yylineno, vector <symbolinfo*>* parameter_list = nullptr)
{
		
    
    symbolinfo*  sym_info =   sym_table.look_up_func(function_name);

		
	if(sym_info == nullptr)
    { 

	   sym_table.insert_symbol(function_name,  "ID");

       sym_info = sym_table.look_up_func(function_name);

	}
    

    
    else
    {
		
		
        if(sym_info->get_info_type() == symbolinfo :: FUNC_DEC)
        {
			
            if(sym_info->get_return_type() != return_type)
            {

				Log_Error("Conflicting types for '" + function_name + "'", line_no);
					
                return;

			}


			vector<pair<string,  string>> temp =  sym_info->get_parameter();


			int parameter_count = parameter_list == nullptr ? 0 : parameter_list->size();


			if(temp.size() !=  parameter_count)
            {

				Log_Error("Conflicting types for '" + function_name + "'", line_no);

				return;

			}


			if(parameter_list != nullptr)
            { 

				vector <symbolinfo*> param = *parameter_list;

				for(int i=0; i<temp.size(); i++)
                {
					
                    if(temp[i].first !=  param[i]->get_data_type())
                    {
						Log_Error("Conflicting argument types for '" + function_name +"'", line_no );

						return;

					}

				}

			}

		}

        
        else
        { 
		    Log_Error("'"+ function_name + "' redeclared as different kind of symbol");

			return;

		}

	}
		
        
    if(sym_info->get_info_type() == symbolinfo :: FUNC_DEF)
    {
		Log_Error("Redefinition of " + function_name, line_no);

		return;
	}


	sym_info->set_info_type(symbolinfo :: FUNC_DEF);

	sym_info->set_return_type(return_type);

	sym_info->set_parameter(vector <pair<string, string>>());


		
	if(parameter_list != nullptr) 
	    for(symbolinfo* ptr: *parameter_list)
        {

		    sym_info->add_parameter(ptr->get_data_type(),  ptr->get_sym_name());

		}



}




void Function_Call(symbolinfo* &sym_function, vector<symbolinfo*>* ptr = nullptr)
{
	
    string function_name = sym_function->get_sym_name();

	symbolinfo* sym_info = sym_table.look_up_func(function_name);

	if(sym_info == nullptr)
    {

	    Log_Error("Undeclared function '" + function_name + "'");

		return;
		
    }


	if(!sym_info->is_function())
    { 

	    Log_Error(function_name + " is not a function");

		return;
		
    }
		
    
    sym_function->set_return_type(sym_info->get_return_type());


	if(sym_info->get_info_type() != symbolinfo :: FUNC_DEF)
    {

		Log_Error("Function " + function_name + " not defined");

		return;
		
    }


	vector <pair<string, string>> temp = sym_info->get_parameter();

	int parameter_count = ptr == nullptr ? 0 : ptr->size();

		
	if(temp.size() != parameter_count)
    {

	    Log_Error("Too few arguments to function '" + function_name + "'");

		return;
		
    }


	if(ptr != nullptr)
    { 
        
        vector <symbolinfo*> ptr_list = *ptr;
			
		for(int i=0; i<temp.size(); i++)
        {

			if(temp[i].first != ptr_list[i]->get_data_type())
            {
				Log_Error("Type mismatch for argument " + to_string(i+1) + " of '" + function_name + "'");

				return;
			}


		}

	}



}





string  Type_Casting(symbolinfo* obj1, symbolinfo* obj2)
{
	if(obj1->get_data_type() == obj2->get_data_type())
    {

        return obj1->get_data_type();

    }


	if(obj1->get_data_type() == "int" && obj2->get_data_type() == "float")
    {

		obj1->set_data_type("float");

		return "float";

	}
    
    else if(obj1->get_data_type() == "float" && obj2->get_data_type() == "int")
    {

	    obj2->set_data_type("float");

		return "float";

	}


	if(obj1->get_data_type() != "void")
    {

		return obj1->get_data_type();

	}


	return obj2->get_data_type();


}




void Void_Function_Check(symbolinfo* obj1, symbolinfo* obj2)
{
	
	if(obj1->get_data_type() == "void" || obj2->get_data_type() == "void")
    {

		Log_Error("Void cannot be used in expression");

	}


}





%}




%union
{

	symbolinfo* sym_info; 

	string* string_info;

	vector <symbolinfo*>* sym_info_list;

}

	
	
%token IF ELSE FOR WHILE DO BREAK INT CHAR FLOAT DOUBLE VOID RETURN SWITCH CASE DEFAULT CONTINUE PRINTLN
	

%token <sym_info> ADDOP MULOP RELOP LOGICOP


%token INCOP DECOP ASSIGNOP NOT

	
%token LPAREN RPAREN LCURL RCURL LSQUARE RSQUARE COMMA SEMICOLON

	
%token <sym_info> CONST_INT CONST_FLOAT CONST_CHAR ID

	
%token STRING 



	
%type <sym_info> variable factor term unary_expression simple_expression rel_expression logic_expression expression


%type <sym_info> expression_statement if_common_part // expression_statement -> expression SEMICOLON is for the loop


%type <string_info> statement statements compound_statement


%type <string_info> type_specifier var_declaration func_declaration func_definition unit program 


%type <sym_info_list>  declaration_list parameter_list argument_list arguments




%nonassoc LOWER_THAN_ELSE


%nonassoc ELSE



%%


// rest of the codes


start  : {

        data_segment_out << ".MODEL SMALL\n.STACK 100h\n.DATA\n\n";

	    code_segment_out << ".CODE\n";	

}  program  { 


		Log_Rule("start : program",  "");

		sym_table.print_all_scope_table(); 

		sym_table.exit_scope();

		cout  <<  "Total Lines: "  <<  yylineno  <<  endl;

		cout  <<  "Total Errors: "  <<  error_counter  <<  endl;

		generate_println_func();

		generate_asm_file();

	}
	;


program  :  program unit  { 

		string  str  =  *$1  +  "\n"  +  *$2;

		Log_Rule("program : program unit",  str);

		$$  =  new  string(str);

		delete  $1;
		
		delete  $2;

	}


	| unit  { 

		Log_Rule("program : unit",  *$1);

		$$  =  $1;

	}
	;




unit : var_declaration {

		Log_Rule("unit : var_declaration",  *$1); 

	}


    | func_declaration {

		Log_Rule("unit : func_declaration",  *$1);

	}


    | func_definition {
		
		Log_Rule("unit : func_definition",  *$1); 

	}
    ;



func_declaration  :  type_specifier  ID  LPAREN  parameter_list  RPAREN  SEMICOLON {

		string  str  =  *$1  +  " "  +  $2->get_sym_name()  +  "("  +  Function_Parameter_List($4)  +  ");";

		Log_Rule("func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON", str);;

		$$  =  new  string(str);

		Declare_Function($2->get_sym_name(),  *$1,  $4);

		delete $1; 

		delete $2; 

		Free_Sym_Info_Vector($4);

	}


	| type_specifier ID LPAREN RPAREN SEMICOLON {

		string str  =  *$1  +  " "  +  $2->get_sym_name()+  "();";

		Log_Rule("func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON", str);

		Declare_Function($2->get_sym_name(), *$1);

		$$  =  new string(str);

		delete $1; 
		
		delete $2;

	}
	;



func_definition : type_specifier ID LPAREN parameter_list RPAREN { 

	    global_scope = false;

		function_start_code($2->get_sym_name());

		Define_Function($2->get_sym_name(), *$1,yylineno, $4);
		
		

	}  compound_statement {

		function_end_code($2->get_sym_name());

		string str = *$1 + " " + $2->get_sym_name() + "(" +Function_Parameter_List($4) + ")" + *$7;	
		
		Log_Rule( "func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement",str);;
		
		$$ = new string(str);
		
		delete $1; 
		
		delete $2; 
		
		delete $7; 
		
		
		Free_Sym_Info_Vector($4);

	}



	| type_specifier ID LPAREN RPAREN { 

		global_scope = false;

		function_start_code($2->get_sym_name());

		Define_Function($2->get_sym_name(), *$1,yylineno);

		

	} compound_statement {

		function_end_code($2->get_sym_name());

		
		string str = *$1 +" "+$2->get_sym_name()+"()"+ *$6;
		
		Log_Rule( "func_definition : type_specifier ID LPAREN RPAREN compound_statement",str);
		
		$$ = new string(str);
		
		delete $1;
		
		delete $2;
		
		delete $6;

	}
	;	





parameter_list  : parameter_list COMMA type_specifier ID { 

		string  str  =  Function_Parameter_List($1);

		str  +=  ","  +  *$3+  " "  +  $4->get_sym_name();

		Log_Rule("parameter_list  : parameter_list COMMA type_specifier ID", str);

		$1->push_back(new symbolinfo($4->get_sym_name(),  "",  *$3));

		$$ = $1;

		function_parameter_list  =  $1; 

		parameter_declaration_line  =  yylineno;

		delete $3;
		
	    delete $4;

	}



	| parameter_list COMMA type_specifier { 

		string str  =  Function_Parameter_List($1);

		str  +=  ","  +  *$3;

		Log_Rule("parameter_list  : parameter_list COMMA type_specifier",  str);

		$1->push_back(new symbolinfo(*$3, ""));

		$$  =  $1;

		function_parameter_list  =  $1; 

		parameter_declaration_line  =  yylineno;

		delete $3;

	}


	| type_specifier ID { 

		string str  =  *$1  + " " +  $2->get_sym_name();

		Log_Rule("parameter_list  : type_specifier ID",  str);

		$$ = new vector<symbolinfo*>();

		$$->push_back(new symbolinfo($2->get_sym_name(),  "",  *$1));

		function_parameter_list  =  $$;

		parameter_declaration_line  =  yylineno;

		delete $1;

	    delete $2;

	}


	
	| type_specifier {

		Log_Rule("parameter_list  : type_specifier",  *$1);

		$$ = new vector<symbolinfo*>();

		$$->push_back(new symbolinfo(*$1,  "",  *$1));

		delete $1;

	}
	;



compound_statement : LCURL {  

	   sym_table.enter_scope();  

	   Declare_Function_Parameter_List(function_parameter_list,  parameter_declaration_line); 

	   } statements RCURL {
		
		string  str  =  "{\n"  +  *$3  +  "\n}\n";

		Log_Rule("compound_statement : LCURL statements RCURL", str);

		$$  =  new string(str);

		delete $3;

		sym_table.print_all_scope_table();
		
		sym_table.exit_scope();

	}


	| LCURL {  sym_table.enter_scope();  } RCURL {

		Log_Rule("compound_statement : LCURL RCURL", "{}");

		$$ = new string("{}");

		sym_table.print_all_scope_table();
		
		sym_table.exit_scope();

	}
	;




var_declaration : type_specifier declaration_list SEMICOLON {

		string str  =  *$1 +  " " +  Variable_Declaration_List($2)  +  ";";

		Log_Rule("var_declaration : type_specifier declaration_list SEMICOLON", str);

		$$ = new string(str);



		for(symbolinfo* sym_info  : *$2)
		{

			if(*$1 == "void")
			{

				Log_Error("Variable or field '" + sym_info->get_sym_name() + "' declared void");

				continue;

			}


			bool flag = sym_table.insert_symbol(sym_info->get_sym_name(), sym_info->get_sym_type());


			if(!flag)
			{

				Log_Error("Conflicting types for '" + sym_info->get_sym_name() +"'");

			}
			
			else
			{
				symbolinfo* newPtr = sym_table.look_up_func(sym_info->get_sym_name());

				newPtr->copy(sym_info);

				newPtr->set_data_type(*$1); 


				if(sym_info->is_array())
				{ 
					
					newPtr->set_array_size(sym_info->get_array_size());

				}

			}

		}

		
		delete $1; 

		
		Free_Sym_Info_Vector($2);


	}
	;





type_specifier	: INT {

		Log_Rule("type_specifier : INT",  "int");

		$$ = new string("int");

	}


	| FLOAT {

		Log_Rule("type_specifier : FLOAT",  "float");

		$$ = new string("float");

	}


	| VOID {

		Log_Rule("type_specifier : VOID",  "void");

		$$ = new string("void");

	}
	;




declaration_list : declaration_list COMMA ID {

		string str = Variable_Declaration_List($1);

		str  +=  "," + $3->get_sym_name(); 

		variable_declaration($3, global_scope);

		$1->push_back($3); 

		Log_Rule("declaration_list : declaration_list COMMA ID",  str);

		$$ = $1;

	}


	| declaration_list COMMA ID LSQUARE CONST_INT RSQUARE {

		string str = Variable_Declaration_List($1);

		str +=  ","  +  $3->get_sym_name() + "[" + $5->get_sym_name()+ "]";

		$3->set_array_size($5->get_sym_name());

		variable_declaration($3, global_scope);

		$1->push_back($3);

		Log_Rule("declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD", str);

		$$ = $1;

		delete $5; 

	}


	| ID {

		Log_Rule("declaration_list : ID",  $1->get_sym_name());


		$$ = new vector <symbolinfo*>();

		$$->push_back($1);

		variable_declaration($1, global_scope);

	}


	
	| ID LSQUARE CONST_INT RSQUARE {

		string str = $1->get_sym_name() + "[" + $3->get_sym_name()+ "]";

		Log_Rule("declaration_list : ID LTHIRD CONST_INT RTHIRD",  str);

		
		$$ = new vector <symbolinfo*>();

		
		$1->set_array_size($3->get_sym_name());


		$$->push_back($1);

		variable_declaration($1, global_scope);

		delete $3;

	}
	;




statements : statement {

		Log_Rule("statements : statement",  *$1);

		$$ = $1;

	}


	| statements statement {

		string str  =  *$1  + "\n" +  *$2;

		Log_Rule("statements : statements statement",  str);

		$$ = new string(str);

		delete $1;
		
		delete $2;

	}
	;



statement : var_declaration {

		Log_Rule("statement : var_declaration",  *$1); 

		generate_codeln("");

	}	


	| expression_statement {

		Log_Rule("statement : expression_statement",  $1->get_sym_name()); 

		generate_codeln("\t\tPOP AX", "evaluated exp: "+$1->get_sym_name()+"\n");

		$$ = new string($1->get_sym_name()); 
		
		delete $1;

	}


	| compound_statement {

		Log_Rule("statement : compound_statement",  *$1);

	}


    | FOR LPAREN {


		label_map.clear();

	} expression_statement { 
		
		
		label_map["forCond"] = new_label("FOR_COND");
		
		label_map["forStmt"] = new_label("FOR_STMT");
		
		label_map["forUpdate"] = new_label("FOR_UPDATE");
		
		label_map["endFor"] = new_label("END_FOR");

		
		generate_codeln("\t\tPOP AX", "evaluated for loop init exp: "+$4->get_sym_name()+"\n");
		
		
		generate_codeln("\t\t"+label_map["forCond"]+":"); 

	} expression_statement { 

		
		generate_codeln("\t\tPOP AX", "load "+$6->get_sym_name()); 
		
		generate_codeln("\t\tCMP AX, 0");
		
		generate_codeln("\t\tJE "+label_map["endFor"], "break for loop"); 
		
		generate_codeln("\t\tJMP "+label_map["forStmt"],"execute for statement");
		
		
		generate_codeln("\t\t"+label_map["forUpdate"]+":"); 


	} expression { 
		
		
		generate_codeln("\t\tPOP AX", "evaluated for loop update exp: "+$8->get_sym_name()+"\n");
		
		generate_codeln("\t\tJMP "+label_map["forCond"],"continue for loop");
		
		
		generate_codeln("\t\t"+label_map["forStmt"]+":");


	} RPAREN statement { 

		string str = "for("+$4->get_sym_name()+$6->get_sym_name()+$8->get_sym_name()+")"+*$11;
		
		Log_Rule("statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement",str);
		
		$$ = new string(str);
		
		
		generate_codeln("\t\tJMP "+label_map["forUpdate"],"go to update section");
		
		
		generate_codeln("\t\t"+label_map["endFor"]+":"); 
		
		
		delete $4;
		
		delete $6;
		
		delete $8;
		
		delete $11;
	}
	| if_common_part %prec LOWER_THAN_ELSE {
		
		generate_codeln("\t\t"+$1->get_label()+":\n");
		

		Log_Rule("statement : IF LPAREN expression RPAREN statement",$1->get_sym_name());
		
		$$ = new string($1->get_sym_name());
		
		delete $1;

	}
	| if_common_part ELSE {
		
		
		string elseEnd = new_label("END_ELSE");
		
		generate_codeln("\t\tJMP "+elseEnd); 
		
		generate_codeln("\t\t"+$1->get_label()+":\n");
		
		
		$1->set_label(elseEnd);

	} statement {
		
		string str = $1->get_sym_name()+"else "+ *$4;
		
		Log_Rule("statement : IF LPAREN expression RPAREN statement ELSE statement",str);
		
		$$ = new string(str);
		
		generate_codeln("\t\t"+$1->get_label()+":\n");
		
		delete $1;
		
		delete $4;
	}
	| WHILE LPAREN {

		
		while_loop = new_label("WHILE_LOOP");
		
		generate_codeln("\t\t"+while_loop+":");

	} expression RPAREN {
		
		
		string whileEnd = new_label("END_WHILE");
		
		generate_codeln("\t\tPOP AX", "load "+$4->get_sym_name());
		
		generate_codeln("\t\tCMP AX,0");
		
		generate_codeln("\t\tJE "+whileEnd);
		
		$4->set_label(while_loop+" "+whileEnd);


	} statement {
		
		string str = "while("+$4->get_sym_name()+")"+*$7;
		
		Log_Rule("statement : WHILE LPAREN expression RPAREN statement",str);
		
		$$ = new string(str);
		
		stringstream ss($4->get_label());
		
		string whileLoop, whileEnd;
		
		ss >> whileLoop >> whileEnd;
		
		generate_codeln("\t\tJMP "+whileLoop);
		
		generate_codeln("\t\t"+whileEnd+":\n");
		
		delete $4;
		
		delete $7;


	}
	| PRINTLN LPAREN ID RPAREN SEMICOLON {
		
		string str = "println("+$3->get_sym_name()+");";
		
		Log_Rule("statement : PRINTLN LPAREN ID RPAREN SEMICOLON",str);
		
		symbolinfo* sym_info = sym_table.look_up_func($3->get_sym_name());
		
		if(sym_info==nullptr){

			Log_Error("Undeclared variable  "+$3->get_sym_name());

		}
		
		else{

			
			generate_codeln("\t\tMOV BX, "+sym_info->get_assembly_name(), "load "+$3->get_sym_name());
			
			generate_codeln("\t\tCALL PRINT_NUM_FROM_BX");

		}

		
		$$ = new string(str);
		
		delete $3;

	}
	| RETURN expression SEMICOLON {

		string str = "return "+$2->get_sym_name()+";";
		
		Log_Rule("statement : RETURN expression SEMICOLON",str);
		
		$$ = new string(str);
		
		if(!is_main)
		{ 
			
			generate_codeln("\t\tPOP AX", "load "+$2->get_sym_name());

			generate_codeln("\t\tMOV [BP+4], AX","\n"); 
			
			
			generate_codeln("\t\tADD SP, "+to_string(sym_table.get_variable_count()*2), "\n");
			
			generate_codeln("\t\tPOP BP"); 	
			
			generate_codeln("\t\tRET"); 

		}

		delete $2;
	}
	;
if_common_part : IF LPAREN expression RPAREN {
	
	string endif = new_label("END_IF");
	
	
	generate_codeln("\t\tPOP AX", "load "+$3->get_sym_name());
	
	generate_codeln("\t\tCMP AX, 0");
	
	generate_codeln("\t\tJE "+endif);
	
	$3->set_label(endif);



} statement {
	

	
	string str = "if("+$3->get_sym_name()+")"+*$6;
	
	$$ = new symbolinfo(str, "nonterminal");
	
	$$->set_label($3->get_label());
	
	delete $3;
	
	delete $6;

};









expression_statement : SEMICOLON {
	
		Log_Rule("expression_statement : SEMICOLON", ";");

		
		generate_codeln("\t\tPUSH 1\n"); 
		
		$$ = new symbolinfo(";", "nonterminal");

	}		


	| expression SEMICOLON {

		string str = $1->get_sym_name() +  ";";

		Log_Rule("expression_statement : expression SEMICOLON",  str);

		$$ = new symbolinfo(str, "nonterminal");

		delete $1;

	}
	;





variable : ID { 

		Log_Rule("variable : ID", $1->get_sym_name());

		symbolinfo* sym_info = sym_table.look_up_func($1->get_sym_name());

		

		if(sym_info != nullptr)
		{
			
			if(sym_info->is_array())
			{

				Log_Error("Type mismatch, " + sym_info->get_sym_name() + " is an array");

			}

			
			
			$$ = new symbolinfo(*sym_info); 
			
			$$->set_assembly_name(get_variable_address(sym_info));

			delete $1; 

		}

		
		else
		{
			Log_Error("Undeclared variable '" + $1->get_sym_name() + "'");

			$$ = $1;

		}

	}



	| ID LSQUARE {array_index = true;} expression RSQUARE {
		
		array_index = false;
		
		string str = $1->get_sym_name()+"["+$4->get_sym_name()+"]";
		
		Log_Rule("variable : ID LTHIRD expression RTHIRD",str);

		
		symbolinfo *sym_info = sym_table.look_up_func($1->get_sym_name());
		
		if(sym_info != nullptr)
		
		{ 
			
			$1->set_data_type(sym_info->get_data_type());
			
			if(!sym_info->is_array())
			{ 

				Log_Error($1->get_sym_name()+" is not an array.");

			}
			
			if($4->get_data_type()!="int")
			{

				Log_Error("Expression inside third brackets not an integer");

			}

			
			$1->copy(sym_info);
			
			
			generate_codeln("\t\tPOP AX","pop index "+$4->get_sym_name()+" of array "+$1->get_sym_name());
			
			generate_codeln("\t\tSHL AX, 1", "multiply by 2 to get offset");
			
			generate_codeln("\t\tLEA BX, "+sym_info->get_assembly_name(), "get array base address");
			
			generate_codeln("\t\tSUB BX, AX", "[BX]->"+str);
			
			generate_codeln("\t\tPUSH BX\n");
			
			$1->set_assembly_name("[BX]");

		}
		
		else
		{

			Log_Error("Undeclared variable "+$1->get_sym_name());

		}

		$1->set_sym_name(str);

		$$ = $1; 
		
		delete $4;
	}
	;




expression : logic_expression {

		Log_Rule("expression : logic_expression", $1->get_sym_name());

		$$ = $1;

	}


	| variable ASSIGNOP logic_expression {

		string str = $1->get_sym_name() + "=" +  $3->get_sym_name();
		
		Log_Rule("expression : variable ASSIGNOP logic_expression", str);

		symbolinfo* sym_info = sym_table.look_up_func($1->get_sym_name());


		if(sym_info != nullptr)
		{
			if(sym_info->get_data_type() == "int" && $3->get_data_type() == "float")
			{

				Log_Error("Type mismatch");

			}

		}


		if($3->get_data_type() == "void")
		{

			Log_Error("Void cannot be used in expression");

		}

		$$ = new symbolinfo(str, "expression", $1->get_sym_type());

		
		generate_codeln("\t\tPOP AX", "load "+$3->get_sym_name());
		
		generate_codeln("\t\tMOV "+get_variable_address($1, true)+", AX", str);
		
		generate_codeln("\t\tPUSH AX", "save "+$1->get_sym_name()+"\n");

		delete $1; 
		
		delete $3;

	}	
	;





logic_expression : rel_expression { 
	
		Log_Rule("logic_expression : rel_expression", $1->get_sym_name());

	}	


	| rel_expression LOGICOP {
		

		
		generate_codeln("\t\tPOP AX", "load "+$1->get_sym_name());
		
		string boolVal = $2->get_sym_name() == "&&" ? "1" : "0";

		
		generate_codeln("\t\tCMP AX, "+boolVal);
		
		string jmpLabel = new_label();
		
		generate_codeln("\t\tJNE "+jmpLabel);
		
		$1->set_label(jmpLabel);


	} rel_expression {


		string str = $1->get_sym_name()+$2->get_sym_name()+$4->get_sym_name();
		
		Log_Rule("logic_expression : rel_expression LOGICOP rel_expression",str);
		
		$$ = new symbolinfo(str,"logic_expression","int");
		
		
		generate_codeln("\t\tPOP AX", "load "+$4->get_sym_name());
		
		string boolVal = $2->get_sym_name() == "&&" ? "1" : "0";
		
		generate_codeln("\t\tCMP AX, "+boolVal);
		
		generate_codeln("\t\tJNE "+$1->get_label());
		
		boolVal = $2->get_sym_name()== "&&"? "1" :"0";
		
		generate_codeln("\t\t\tPUSH "+boolVal);
		
		string logicEnd = new_label();
		
		generate_codeln("\t\t\tJMP "+logicEnd);
		
		generate_codeln("\t\t"+$1->get_label()+":");
		
		boolVal = $2->get_sym_name()== "&&"? "0" :"1";
		
		generate_codeln("\t\t\tPUSH " +boolVal);
		
		generate_codeln("\t\t"+logicEnd+":\n");
		
		delete $1,$2,$4;

	}	
	;





rel_expression : simple_expression {

		Log_Rule("rel_expression : simple_expression", $1->get_sym_name());

	}


	| simple_expression RELOP simple_expression	{

		string str = $1->get_sym_name() + $2->get_sym_name() + $3->get_sym_name();

		Log_Rule("rel_expression : simple_expression RELOP simple_expression", str);

		Type_Casting($1, $3);

		$$ = new symbolinfo(str, "rel_expression", "int");


		
		string trueL = new_label();
		
		string endL = new_label();
		
		string op = relop_jump($2->get_sym_name());
		
		
		generate_codeln("\t\tPOP BX", "load "+$3->get_sym_name());
		
		generate_codeln("\t\tPOP AX", "load "+$1->get_sym_name());
		
		generate_codeln("\t\tCMP AX, BX");
		
		generate_codeln("\t\t"+op+" "+trueL, str);
		
		generate_codeln("\t\t\tPUSH 0\n\t\t\tJMP "+endL);
		
		generate_codeln("\t\t"+trueL+":\n\t\t\tPUSH 1");
		
		generate_codeln("\t\t"+endL+":\n");

		delete $1,$2,$3;

	}
	;






simple_expression : term {

		Log_Rule("simple_expression : term", $1->get_sym_name());
		
	}	


	| simple_expression ADDOP term {

		string str = $1->get_sym_name() + $2->get_sym_name()  + $3->get_sym_name();
		
		Log_Rule("simple_expression : simple_expression ADDOP term",  str);

		Void_Function_Check($1,  $3);

		$$ = new symbolinfo(str,  "simple_expression",  Type_Casting($1,  $3));

		
		generate_codeln("\t\tPOP BX", "load "+$3->get_sym_name());
		
		generate_codeln("\t\tPOP AX", "load "+$1->get_sym_name());
		
		string op = $2->get_sym_name() == "+" ? "ADD" : "SUB";
		
		generate_codeln("\t\t"+op+" AX, BX");
		
		generate_codeln("\t\tPUSH AX", "save "+$1->get_sym_name()+"\n");


		delete $1;
	   
	    delete $2; 
		
		delete $3;

	} 
	;






term :	unary_expression {

		Log_Rule("term : unary_expression", $1->get_sym_name());

	}

    |  term MULOP unary_expression {

		string str = $1->get_sym_name() + $2->get_sym_name()  + $3->get_sym_name();

		Log_Rule("term : term MULOP unary_expression", str);

		Void_Function_Check($1,  $3);


		if($2->get_sym_name() == "%")
		{

			if($3->get_sym_name() == "0") 
			{

				Log_Error("Warning: division by zero i=0f=1Const=0");

			}


		
			if($1->get_data_type() != "int" || $3->get_data_type() != "int")
			{

				Log_Error("Operands of modulus must be integers");

			}

			$1->set_data_type("int");

			$3->set_data_type("int");

		}

		
		generate_codeln("\t\tPOP BX", "load "+$3->get_sym_name());
		
		generate_codeln("\t\tPOP AX", "load "+$1->get_sym_name());
		
		generate_codeln("\t\tXOR DX, DX", "clear DX");
		
		string op = $2->get_sym_name() == "*" ? "IMUL" : "IDIV";
		
		generate_codeln("\t\t"+op+" BX", str);
		
		string result = $2->get_sym_name() == "%" ? "DX" : "AX";
		
		generate_codeln("\t\tPUSH "+result, "save "+str+"\n");

		$$ = new symbolinfo(str,  "term",  Type_Casting($1, $3));

		delete $1; 
		
		delete $2; 
		
		delete $3;


	}
    ;




unary_expression : ADDOP unary_expression {

		string str = $1->get_sym_name() + $2->get_sym_name();

		Log_Rule("unary_expression : ADDOP unary_expression", str);

		$$ = new symbolinfo(str, "unary_expression",  $2->get_data_type());

		if($1->get_sym_name() == "-")
		{
			
			generate_codeln("\t\tPOP AX");
			
			generate_codeln("\t\tNEG AX");
			
			generate_codeln("\t\tPUSH AX\n");

		}

		delete $1; 
		
		delete $2;

	}  


	| NOT unary_expression {

		string str =  "!" +  $2->get_sym_name();

		Log_Rule("unary_expression : NOT unary_expression", str);

		$$ = new symbolinfo(str, "unary_expression", $2->get_data_type());


		
		string l1 = new_label();
		
		string l2 = new_label(); 
	
		
		generate_codeln("\t\tPOP AX\t\t;load "+$2->get_sym_name());
		
		generate_codeln("\t\tCMP AX, 0");
		
		generate_codeln("\t\tJE "+l1);
		
		generate_codeln("\t\t\tPUSH 0");
		
		generate_codeln("\t\t\tJMP "+l2);
		
		generate_codeln("\t\t"+l1+":\n\t\tPUSH 1\n");
		
		generate_codeln("\t\t"+l2+":");

		delete $2;

	} 



	| factor {

		Log_Rule("unary_expression : factor", $1->get_sym_name());

	} 
	;



	

factor	: variable {

		Log_Rule("factor : variable", $1->get_sym_name());

		generate_codeln("\t\tPUSH "+get_variable_address($1, true), "save "+$1->get_sym_name()+"\n");

		$$ = $1;

	}



	| ID LPAREN {

		

	} argument_list RPAREN { 

		string str = $1->get_sym_name() + "(" + Symbol_Name_List($4) + ")";
		
		Log_Rule("factor : ID LPAREN argument_list RPAREN",str);
		
		Function_Call($1,$4);
		
		$$ = new symbolinfo(str, "function", $1->get_return_type());
		
		generate_codeln("\t\tPUSH 0", "location for return value"); 
		
		generate_codeln("\t\tCALL "+$1->get_sym_name(), "call function"+$1->get_sym_name());
		
		generate_codeln("\t\tPOP AX", "load return value");
		
		generate_codeln("\t\tADD SP,"+to_string($4->size()*2), "pop function param from stack");
		
		if($1->get_return_type() != "void")
		{

			generate_codeln("\t\tPUSH AX", "save return value");

		}
		
		else
		{

			generate_codeln("\t\tPUSH 0", "save dummy return value for void");
			
		}

		
		delete $1; 
		
		Free_Sym_Info_Vector($4);
	}



	| LPAREN expression RPAREN {

		string str = "(" + $2->get_sym_name() +  ")";

		Log_Rule("factor : LPAREN expression RPAREN", str);

		$$ = new symbolinfo(str , "factor", $2->get_data_type());

		delete $2;

	}




	| CONST_INT { 

		Log_Rule("factor : CONST_INT", $1->get_sym_name());

		generate_codeln("\t\tPUSH " + $1->get_sym_name(), "save "+$1->get_sym_name()+"\n");

		$$ = new symbolinfo($1->get_sym_name(), $1->get_sym_type(),  "int");

	}


	| CONST_FLOAT { 

		Log_Rule("factor : CONST_FLOAT", $1->get_sym_name());
	
        generate_codeln("\t\tPUSH " + $1->get_sym_name(), "save "+$1->get_sym_name()+"\n");

		$$ = new symbolinfo($1->get_sym_name(), "factor",  "float");

	}



	| variable INCOP {

		string str = $1->get_sym_name() + "++";

		Log_Rule("factor : variable INCOP", str);

		unary_operation($1);

		$$ = new symbolinfo(str, "factor", $1->get_data_type());

		delete $1;

	}



	| variable DECOP {

		string str = $1->get_sym_name() + "--";

		Log_Rule("factor : variable DECOP",str);

		unary_operation($1, false);

		$$ = new symbolinfo(str, "factor", $1->get_data_type());

		delete $1;

	}
	;





argument_list : arguments {

		string str = Symbol_Name_List($1);

		Log_Rule("argument_list : arguments", str);

		$$ = $1;

	}


	| 
	{
		
		Log_Rule("argument_list :","");

		$$ = new vector <symbolinfo*>();

	}
	;



	

arguments : arguments COMMA logic_expression {

		string str =  Symbol_Name_List($1) +  ","  +  $3->get_sym_name();

		Log_Rule("arguments : arguments COMMA logic_expression",  str);

		$$->push_back($3);

	}



	| logic_expression {
		
		Log_Rule("arguments : logic_expression", $1->get_sym_name());

		$$ = new vector <symbolinfo*>(); 

		$$->push_back($1);

	}
	;


// end of rules



%%



int main(int  argc,  char  *argv[])
{


    if(argc != 2)
	{

        cout << "Please, provide input file name and try again!!!" << endl;

        return 0;

    }



    FILE *fin = freopen(argv[1], "r", stdin);



    if(fin == nullptr)
	{

        cout << "Can't open specified file!!!" << endl;

        return 0;

    }



	cout << argv[1] << " opened successfully." << endl;




    open_files();
    
    yyin = fin;


    yylineno = 1; 

    
	yyparse();


    


    fclose(yyin);




    return 0;


}

