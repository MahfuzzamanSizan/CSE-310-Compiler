// scope table class

#include<iostream>
#include <bits/stdc++.h>
#include "1905054_symbolinfo.h"
#include <string>

using namespace std;

class scopetable
{
private:
    // variables
    int bucket_size;
    int child_scope;
    int id;
    symbolinfo **hash_table;
    scopetable *parent_scope;

    static unsigned long long int sdbm_hash(string sym_name)
    {
        unsigned long long int hash = 0;
        unsigned int i = 0;
        unsigned int length = sym_name.length();

        for (i = 0; i < length; i++)
        {
            hash = (sym_name[i]) + (hash << 6) + (hash << 16) - hash;
        }
        return hash;
    }

    int calculate_hash(string key)
    {
        return (sdbm_hash(key) % bucket_size);
    }

public:
    // constructor

    scopetable(int bucket_size)
    {
        this->bucket_size = bucket_size;
        this->child_scope = 0;
        this->id = 1;
        hash_table = new symbolinfo *[bucket_size];

        for (int i = 0; i < bucket_size; i++)
        {
            hash_table[i] = nullptr;
        }

        parent_scope = nullptr;
    }

    scopetable(int bucket_size, scopetable *parent_scope, int id)
    {

        this->bucket_size = bucket_size;
        this->child_scope = 0;
        this->id = id;
        hash_table = new symbolinfo *[bucket_size];
        this->parent_scope = parent_scope;

        for (int i = 0; i < bucket_size; i++)
        {
            hash_table[i] = nullptr;
        }

        /*cout << "\tScopeTable# " << id << " created" << endl;*/
    }

    // destructor

    ~scopetable()
    {
        /*cout << "\tScopeTable# " << id << " removed" << endl;*/
        for (int i = 0; i < bucket_size; i++)
        {
            if (hash_table[i] != nullptr)
            {
                symbolinfo *symbol_ptr = hash_table[i];
                while (symbol_ptr != nullptr)
                {
                    symbolinfo *temp_ptr = symbol_ptr;
                    symbol_ptr = symbol_ptr->get_obj_ptr();
                    delete temp_ptr;
                }
            }
        }

        delete[] hash_table;
    }

    // getter method
    scopetable *get_parent_scope()
    {
        return parent_scope;
    }

    int get_id()
    {
        return id;
    }

    // look up function
    symbolinfo *look_up_symbol(string sym_name)
    {
        int hash_id = calculate_hash(sym_name);
        int position = 0;

        if (hash_table[hash_id] != nullptr)
        {
            symbolinfo *current_ptr = hash_table[hash_id];
            while (current_ptr != nullptr)
            {
                if (current_ptr->get_sym_name() == sym_name)
                {
                    cout << "\t"
                         << "'" << sym_name << "'"
                         << " found in ScopeTable# " << id << " at position " << hash_id + 1 << ", " << position + 1 << endl;
                    return current_ptr;
                }

                current_ptr = current_ptr->get_obj_ptr();
                position++;
            }
        }

        return nullptr;
    }

    // insert function

    bool insert_scopetable(string sym_name, string sym_type)
    {
        // cout << "ScopeTable# " <<  id  << " created" << endl;

        int position = 1;
        int hash_id = calculate_hash(sym_name);

        if (hash_table[hash_id] == nullptr)
        {
            hash_table[hash_id] = new symbolinfo(sym_name, sym_type);
            /*cout << "\tInserted in ScopeTable# " << id << " at position " << hash_id + 1 << ", " << 1 << endl;
            */return true;
        }

        symbolinfo *current_ptr = hash_table[hash_id];
        symbolinfo *prev_ptr = nullptr;
        while (current_ptr != nullptr)
        {
            if (current_ptr->get_sym_name() == sym_name)
            {
                cout << "\t" << sym_name << " already exisits in the current ScopeTable" << endl;
                return false;
            }

            position++;
            prev_ptr = current_ptr;
            current_ptr = current_ptr->get_obj_ptr();
        }

        prev_ptr->set_obj_ptr(new symbolinfo(sym_name, sym_type));
        /*cout << "\tInserted in ScopeTable# " << id << " at position " << hash_id + 1 << ", " << position << endl;

        */return true;
    }

    // delete function

    bool delete_scopetable(string sym_name)
    {

        int position = 0;
        int hash_id = calculate_hash(sym_name);

        symbolinfo *current_ptr = hash_table[hash_id];
        symbolinfo *prev_ptr = nullptr;

        while (current_ptr != nullptr)
        {
            if (current_ptr->get_sym_name() == sym_name)
            {
                // cout << "\tFound in Scope Table # " << id << " at position " << hash_id+1 << ", " << position+1 << endl;
                if (prev_ptr == nullptr)
                {
                    hash_table[hash_id] = current_ptr->get_obj_ptr();
                }

                else
                {
                    prev_ptr->set_obj_ptr(current_ptr->get_obj_ptr());
                }

                delete current_ptr;
                cout << "\tDeleted '" << sym_name << "' from ScopeTable# " << id << " at position " << hash_id + 1 << ", " << position + 1 << endl;
                return true;
            }

            prev_ptr = current_ptr;
            position++;
            current_ptr = current_ptr->get_obj_ptr();
        }

        cout << "\tNot found in the current ScopeTable" << endl;
        return false;
    }

    // print function

    void print_scopetable()
    {

        cout << "\tScopeTable# " << id << endl;

        for (int i = 0; i < bucket_size; i++)
        {
            
            symbolinfo *temp_ptr = hash_table[i];
            if(temp_ptr!=nullptr)
            {
            cout << "\t" << i + 1 << "--> ";
            while (temp_ptr != nullptr)
            {
                // cout << "< " << temp_ptr->get_sym_name() << " : " << temp_ptr->get_sym_type() << " >";
                //cout << "\t" << i + 1 << "--> ";
                cout << *temp_ptr << " ";
                temp_ptr = temp_ptr->get_obj_ptr();
                
            }

            cout << endl;
            }
        }
    }
};
