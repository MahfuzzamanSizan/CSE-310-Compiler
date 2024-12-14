// symbol info class

#include <iostream>
#include <bits/stdc++.h>
#include <string>

using namespace std;

class symbolinfo
{
private:
    string sym_name;
    string sym_type;
    symbolinfo *obj_ptr;

public:
    // constructor
    symbolinfo(string sym_name, string sym_type)
    {
        this->sym_name = sym_name;
        this->sym_type = sym_type;
        this->obj_ptr = nullptr;
    }

    // destructor
    ~symbolinfo()
    {
        // nothing to free
    }

    // copy contructor
    symbolinfo(const symbolinfo &c)
    {
        this->sym_name = c.sym_name;
        this->sym_type = c.sym_type;
        this->obj_ptr = c.obj_ptr;
    }

    // setter method

    void set_sym_name(string sym_name)
    {
        this->sym_name = sym_name;
    }

    void set_sym_type(string sym_type)
    {
        this->sym_type = sym_type;
    }

    void set_obj_ptr(symbolinfo *obj_ptr)
    {
        this->obj_ptr = obj_ptr;
    }

    // getter method

    string get_sym_name()
    {
        return sym_name;
    }

    string get_sym_type()
    {
        return sym_type;
    }

    symbolinfo *get_obj_ptr()
    {
        return obj_ptr;
    }

    friend ostream &operator<<(ostream &os, const symbolinfo &obj)
    {
        os << "<" << obj.sym_name << "," << obj.sym_type << ">";
        return os;
    }
};
