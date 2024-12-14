//main function
#include<iostream>
#include<bits/stdc++.h>
#include<stdlib.h>
#include "1905054_symboltable.h"

using namespace std;

int adv_tokenizer(string s, string inp[])
{
    stringstream ss(s);
    string word;
    int c=0;
    while (getline(ss, word, ' '))
    {
        inp[c++] = word;
    }
    return c;
}

int main()

{
    //read and write to file
    freopen("sample_input.txt", "r", stdin);
    freopen("outputFile.txt", "w", stdout);

    //variables and input
    int bucket_size;
    string name, type,line;
    getline(cin,line);
    bucket_size = stoi(line);
    //cin>> bucket_size;

    symboltable *sym_obj = new symboltable(bucket_size);

    string ch1, ch2;



    int k=1;
    while(1)
    {
        getline(cin,line);
        string str[100];
        int c = adv_tokenizer(line, str);
        ch1 = str[0];
        cout<< "Cmd " << k << ": " << line<<endl;


        if(ch1=="I")

        {

            if(c==3)
            {
                name = str[1];
                type = str[2];
                //cout << "Cmd " << k << ": " << ch1 << " " << name << " " << type  << endl;
                sym_obj->insert_symbol(name,type);
            }
            else cout << "\tNumber of parameters mismatch for the command I\n" ;
        }

        if(ch1=="L")

        {
            if(c==2)
            {
                name = str[1];
                //cout << "Cmd " << k << ": " << ch1 << " " << name << endl;
                sym_obj->look_up_func(name);

            }

            else
            {
                cout << "\tNumber of parameters mismatch for the command L\n" ;

            }
        }




        if(ch1=="D")

        {
            if(c==2)
            {
                name = str[1];
                //cout << "Cmd " << k << ": " <<  ch1 << " " << name  << endl;
                sym_obj->remove_symbol(name);
            }
            else cout << "\tNumber of parameters mismatch for the command D\n" ;

        }

        if(ch1=="P")

        {
            if(c==2)
            {
                ch2=str[1];
                //cout << "Cmd " << k << ": " <<  ch1 << " " << ch2 <<  endl;
                if(ch2=="A")
                {
                    //print all the scope table
                    sym_obj->print_all_scope_table();
                }
                else if(ch2=="C")
                {
                    //print current scope table
                    sym_obj->print_current_scope_table();
                }
            }
            else cout << "\tNumber of parameters mismatch for the command P\n" ;

        }

        if(ch1=="S")
        {
            //entering a new scope
            if(c==1)
            {
                //cout << "Cmd " << k << ": " << ch1 << endl;
                sym_obj->enter_scope();
                //cout << "New Scope Table created with id " << sym_obj.get_current_id() << endl;
            }
            else  cout << "\tNumber of parameters mismatch for the command S\n" ;
        }
        if(ch1=="E")
        {
            if(c==1)
            {
                //exiting the current scope, can't exit the root scope table
                //cout << "Cmd " << k << ": " << ch1 << endl;
                sym_obj->exit_scope();
            }
            else  cout << "\tNumber of parameters mismatch for the command E\n" ;
        }
        if(ch1=="Q")
        {
            if(c==1)
            {
                //exiting the program
                delete sym_obj;
                break;
            }
            else cout << "\tNumber of parameters mismatch for the command Q\n" ;
        }


        //cout << "\tInvalid input given\n";


        k++;

    }

    return 0;

}


