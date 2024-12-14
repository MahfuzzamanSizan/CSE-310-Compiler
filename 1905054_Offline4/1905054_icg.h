#include<bits/stdc++.h>

#include "1905054_symboltable.h"

using namespace std;


int label_count = 0;
int temp_count = 0;


string main_terminate;
bool is_main = false;

int global_variable_count = 0;
int local_variable_count = 0;

/*----------------*/

int yylex(void);
int yyparse(void);

extern FILE *yyin;
extern int yylineno;

symboltable sym_table = symboltable(31);

int error_counter = 0;

ofstream error_out_file;
ofstream data_segment_out; 
ofstream code_segment_out; 
ofstream assembly_code_out; 

const string data_file = "dataSegment.txt";      
const string code_file = "codeSegment.txt";  


vector<symbolinfo *> *func_parameter_list = nullptr;

int param_declaration_line;






void generate_my_println_func()
{

    char *new_string = "PRINT_NUM_FROM_BX PR"
                "OC\r\n"
                "    PUSH CX  \r\n"
                "    MOV AX, \'X\'\r"
                "\n"
                "    PUSH AX\r\n"
                "    \r\n"
                "    CMP BX, 0  \r\n"
                "    JE ZERO_NUM\r\n"
                "    JNL NON_NEGATIVE"
                " \r\n"
                "    \r\n"
                "    NEG BX\r\n"
                "    MOV DL, \'-\'\r"
                "\n"
                "    MOV AH, 2\r\n"
                "    INT 21H\r\n"
                "    JMP NON_NEGATIVE"
                "  \r\n"
                "    \r\n"
                "    ZERO_NUM:\r\n"
                "        MOV DX, 0\r"
                "\n"
                "        PUSH DX\r\n"
                "        JMP POP_PRIN"
                "T_LOOP\r\n"
                "    \r\n"
                "    NON_NEGATIVE:\r"
                "\n"
                "    \r\n"
                "    MOV CX, 10 \r\n"
                "    \r\n"
                "    MOV AX, BX\r\n"
                "    PRINT_LOOP:\r\n"
                "        CMP AX, 0\r"
                "\n"
                "        JE END_PRINT"
                "_LOOP\r\n"
                "        MOV DX, 0  \r\n"
                "        DIV CX\r\n"
                "    \r\n"
                "        PUSH DX\r\n"
                "        \r\n"
                "        JMP PRINT_LO"
                "OP\r\n\r\n"
                "    END_PRINT_LOOP:"
                "\r\n"
                "    \r\n"
                "    \r\n"
                "    \r\n"
                "    POP_PRINT_LOOP:"
                "\r\n"
                "        POP DX\r\n"
                "        CMP DX, \'X"
                "\'\r\n"
                "        JE END_POP_P"
                "RINT_LOOP\r\n"
                "        \r\n"
                "        CMP DX, \'-"
                "\'\r\n"
                "        JE PRINT_TO_"
                "CONSOLE\r\n"
                "        \r\n"
                "        ADD DX, 30H "
                "      \r\n"
                "        PRINT_TO_CON"
                "SOLE:\r\n"
                "        MOV AH, 2\r"
                "\n"
                "        INT 21H\r\n"
                "        \r\n"
                "        JMP POP_PRIN"
                "T_LOOP\r\n"
                "    \r\n"
                "    END_POP_PRINT_LO"
                "OP: \r\n"
                "CALL PRINT_NEWLINE\r\n"
                "    POP CX\r\n"
                "    RET\r\n"
                "PRINT_NUM_FROM_BX EN"
                "DP";


    code_segment_out << new_string << endl;


}





void optimized_code()
{

    ifstream codeSegmentIn("1905054_code.asm");

    
    ofstream optimizeOut("1905054_optimized_code.asm", ios::out);


    vector<string> lines;

    string line;

    while (getline(codeSegmentIn, line))
    {

        lines.push_back(line);

    }

    for (int i = 0; i < lines.size(); i++)
    {

        if (i + 1 >= lines.size() || lines[i].size() < 4 || lines[i + 1].size() < 4)
        {

        }


        else if (lines[i].substr(1, 3) == "MOV" && lines[i + 1].substr(1, 3) == "MOV")
        {
            string str1 = lines[i].substr(4);

            string str2 = lines[i + 1].substr(4);


            int index1 = str1.find(",");
            int index2 = str2.find(",");

            if (str1.substr(1, index1 - 1) == str2.substr(index2 + 2))

                if (str1.substr(index1 + 2) == str2.substr(1, index2 - 1))
                {

                    optimizeOut << "\t; Redundant MOV optimized" << endl;

                    i++;

                    continue;

                }

        }

        optimizeOut << lines[i] << endl;

    }

    optimizeOut.close();

    codeSegmentIn.close();

}






void print_new_line()
{

    string new_string = "\n\tPRINT_NEWLINE PROC\r"
                 "\n\r\n"
                 "        PUSH AX\r\n"
                 "        PUSH DX\r\n"
                 "        MOV AH, 2\r"
                 "\n"
                 "        MOV DL, 0Dh"
                 "\r\n"
                 "        INT 21h\r\n"
                 "        MOV DL, 0Ah"
                 "\r\n"
                 "        INT 21h\r\n"
                 "        POP DX\r\n"
                 "        POP AX\r\n"
                 "        RET\r\n"
                 "    PRINT_NEWLINE EN"
                 "DP";
    code_segment_out << new_string << endl;

}



void generate_println_func()
{
    print_new_line();

    code_segment_out << endl;

    generate_my_println_func();

}









void open_files()
{
    error_out_file.open("1905054_error.txt", ios::out);

    freopen("1905054_log.txt", "w", stdout);

    data_segment_out.open(data_file, ios::out);

    code_segment_out.open(code_file, ios::out);

}


void generate_asm_file()
{
    
    if (data_segment_out.is_open())
    {

        data_segment_out.close();

    }

    if (code_segment_out.is_open())
    {

        code_segment_out.close();

    }

    ifstream dataSegmentIn(data_file);

    ifstream codeSegmentIn(code_file);

    ofstream codeDotAsmOut("1905054_code.asm", ios::out);

    string line;

    while (getline(dataSegmentIn, line))
    {

        codeDotAsmOut << line << endl;

    }

    codeDotAsmOut << endl;


    while (getline(codeSegmentIn, line))
    {

        codeDotAsmOut << line << endl;

    }

    codeDotAsmOut << endl << "END MAIN" << endl;

    dataSegmentIn.close();

    codeSegmentIn.close();

    codeDotAsmOut.close();

    remove(data_file.c_str());

    remove(code_file.c_str());

    optimized_code();
}




/*--------------------*/




string new_label()
{

    return "@L_" + to_string(label_count++);

}

string new_label(string label_name)
{

    return "@"+label_name+"_" + to_string(label_count++);

}



void generate_code(string assembly_code, string comment = "")
{
    code_segment_out << assembly_code << "\t";

}

void generate_codeln(string assembly_code, string comment = "")
{

    generate_code(assembly_code, comment);

    code_segment_out << endl;

}

string get_variable_address(symbolinfo *variable, bool pop = false)
{
    if (pop)
    {
        if (variable->is_array() && !variable->is_global())
        {

          generate_codeln("\t\tPOP BX");

        }
            
    }

    return variable->get_assembly_name();
}







void function_start_code(string func_name)
{

    code_segment_out << "\t" << func_name << " PROC\n";

    if (func_name == "main")
    {
        main_terminate = new_label();

        code_segment_out << "\t\tMOV AX, @DATA\n\t\tmov DS, AX\n\n";

        is_main = true;

    }

    else
    {
        is_main = false;

        generate_codeln("\t\tPUSH BP"); 

    }

    generate_codeln("\t\tMOV BP, SP\n");

}


void function_end_code(string func_name)
{

    if (func_name == "main")
    {
        code_segment_out << "\n\t\t" << main_terminate << ":" << endl;

        code_segment_out << "\t\tMOV AH, 4CH" << endl;
        
        code_segment_out << "\t\tINT 21H" << endl;
    }
    
    else
    {
        
        generate_codeln("\t\tPOP BP");

        code_segment_out << "\t\tRET\n";
        
        is_main = true;

    }

    code_segment_out << "\t" << func_name << " ENDP\n\n";

}



void unary_operation(symbolinfo *sym_info, bool increment = true)
{
    string op = increment ? "INC" : "DEC";

    string address = get_variable_address(sym_info, true);

    generate_codeln("\t\tPUSH " + address);

    generate_codeln("\t\t" + op + " " + address, sym_info->get_sym_name() + (increment ? "++" : "--"));

}




string relop_jump(string relational_operator)

{
    if(relational_operator == "<") {

        return "JL";

    }

    if(relational_operator == "<=") {

        return "JLE";

    }

    if(relational_operator == ">") {

        return "JG";

    }

    if(relational_operator == ">=") {

        return "JGE";

    }
    
    if(relational_operator == "==") {

        return "JE";

    }
    
    if(relational_operator == "!=") {

        return "JNE";

    }

}





void variable_declaration(symbolinfo *variable_info, bool global_scope = false)
{
    if (global_scope)
    {
        data_segment_out << "\t" << variable_info->get_sym_name();

        data_segment_out << " DW " << variable_info->get_array_size();

        if (variable_info->is_array())
        {

            data_segment_out << " DUP(" << 0 << ")";

            data_segment_out << "\t\t; array " << variable_info->get_sym_name() << " declared";

        }


        else
        {

            data_segment_out << "0";  

        }


        variable_info->set_assembly_name(variable_info->get_sym_name(), true); 

        data_segment_out << endl;

    }


    else
    {
        if (variable_info->is_array())
        {

            int temp = stoi(variable_info->get_array_size());

            int array_start = ((sym_table.get_variable_count() + 1) * 2);

            string base_address = "W. [BP-" + to_string(array_start) + "]";

            variable_info->set_assembly_name(base_address, false, array_start);

            sym_table.variable_count_add(temp);

            code_segment_out << "\t\tSUB SP, " << (temp * 2) << "\t\n";
            
        
        }


        else
        {
            sym_table.variable_count_add(1);

            variable_info->set_assembly_name("W. [BP-" + to_string(2 * sym_table.get_variable_count()) + "]");
            
            code_segment_out << "\t\tSUB SP, 2\t\n";
            
        }

    }

}



