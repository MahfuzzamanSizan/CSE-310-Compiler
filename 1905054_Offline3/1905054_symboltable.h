// symbol table class

#include <iostream>
#include <bits/stdc++.h>
#include <string>


#include "1905054_scopetable.h"


using namespace std;


class symboltable
{

private:


    // variables

    int tableSize;
    int id;

    scopetable *currentTable;
    scopetable *rootTable;
    


public:


    // constructor

    symboltable(int tableSize)
    {
        this->id = 1;

        this->tableSize = tableSize;

        rootTable = new scopetable(tableSize, nullptr, id++);

        currentTable = rootTable;
    }



    // destructor

    ~symboltable()
    {

        scopetable *scope = currentTable;


        while (scope != nullptr)
        {
            currentTable = scope->get_parent_scope();

            delete scope;

            scope = currentTable;

        }

    }



    // enter scope function

    void enter_scope()
    {

        currentTable = new scopetable(tableSize, currentTable, id++);

    }



    // exit scope function

    void exit_scope()
    {

        if (currentTable->get_parent_scope() != nullptr)

        {
            if (currentTable != nullptr)
            {
                // string current_id= currentTable->get_id();

                scopetable *previous_table = currentTable;

                currentTable = currentTable->get_parent_scope();

                // cout << "\tScopeTable# " << previous_table->get_id() << " removed"  << endl;

                delete previous_table;
            }

            else
            {
                cout << "\tNo current scope" << endl;

                return;
            }
        }


        else
            cout << "\tScopeTable# " << currentTable->get_id() << " cannot be removed" << endl;

    }




    // insert symbol function

    bool insert_symbol(string sym_name, string sym_type)
    {

        if (currentTable == nullptr)
        {

            currentTable = new scopetable(tableSize, nullptr, id);

        }

        return currentTable->insert_scopetable(sym_name, sym_type);

    }




    // remove symbol function

    bool remove_symbol(string sym_name)
    {

        if (currentTable == nullptr)
        {
            // cout << "No current scope\n";

            return false;

        }

        return currentTable->delete_scopetable(sym_name);

    }




    // look up function

    symbolinfo *look_up_func(string sym_name)
    {

        if (currentTable == nullptr)
        {

            return nullptr;

        }


        // scopetable *scope_ptr = currentTable;

        symbolinfo *symbol_ptr = currentTable->look_up_symbol(sym_name);


        if (symbol_ptr == nullptr)
        {

            scopetable *scope_ptr = currentTable->get_parent_scope();

            while (scope_ptr != nullptr)
            {
                symbol_ptr = scope_ptr->look_up_symbol(sym_name);

                if (symbol_ptr != nullptr)
                {
                    break;
                }

                scope_ptr = scope_ptr->get_parent_scope();
            }

        }

        /*
        if (symbol_ptr == nullptr)
            cout << "\t'" << sym_name << "' not found in any of the ScopeTables" << endl;  */

        return symbol_ptr;

    }




    // print current scope table

    void print_current_scope_table()
    {

        if (currentTable == nullptr)
        {
            // cout << "No current scope\n";

            return;
        }

        currentTable->print_scopetable();
    }




    // print all scope table

    void print_all_scope_table()
    {
        scopetable *scope = currentTable;

        while (scope != nullptr)
        {
            scope->print_scopetable();

            scope = scope->get_parent_scope();

        }

        if (scope == nullptr)
        {
            // cout << "No current scope\n";

            return;
        }

    }



};
