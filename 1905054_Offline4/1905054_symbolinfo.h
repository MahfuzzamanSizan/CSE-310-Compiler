#include "bits/stdc++.h"

using namespace std;


class symbolinfo
{

private:


   //variables

    string sym_name;
    string sym_type;

    symbolinfo *obj_ptr;

    string array_size;
    string data_type;

    int info_type;

    vector<pair<string, string>> parameter;



    //for assembly code

    string assembly_name;
    int array_start;
    bool global_var;
    string label;


public:


    static const int VAR = 1;
    static const int FUNC_DEC = 2;
    static const int FUNC_DEF = 3;

    vector <symbolinfo*> child_list;

    int start_line;
    int end_line;

    string rule;
    bool is_leaf;


    


   


    // constructors

    symbolinfo(string sym_name, string sym_type)
    {

        this->sym_name = sym_name;

        this->sym_type = sym_type;

        this->obj_ptr = nullptr;

        this->array_size = array_size;

        this->data_type = "";

        this->info_type = VAR;

        this->parameter.clear();

    }




    symbolinfo(string sym_name, string sym_type, string data_type, int info_type = VAR, string array_size = "")
    {

        this->sym_name = sym_name;

        this->sym_type = sym_type;

        this->obj_ptr = nullptr;

        this->array_size = array_size;

        this->data_type = data_type;

        this->info_type = info_type;

        this->parameter.clear();

    }




    symbolinfo(symbolinfo *sym_info)
    {

        this->sym_name = sym_info->sym_name;

        this->sym_type = sym_info->sym_type;

        this->obj_ptr = sym_info->obj_ptr;

        this->array_size = sym_info->array_size;

        this->data_type = sym_info->data_type;

        this->info_type = sym_info->info_type;

        this->parameter = sym_info->parameter;

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

        this->data_type = c.data_type;

        this->info_type=c.info_type;

        this->parameter=c.parameter;

    }



    void copy(symbolinfo* ptr)
    {
        this->sym_name = ptr->sym_name;

        this->sym_type = ptr->sym_type;

        this->obj_ptr = ptr->obj_ptr;

        this->array_size = ptr->array_size;

        this->assembly_name = ptr->assembly_name;

        this->array_start = ptr->array_start;

        this->global_var = ptr->global_var;

        this->data_type = ptr->data_type;

        this->info_type = ptr->info_type;

        this->parameter = ptr->parameter;

    }



    // setter methods

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



    void set_array_size(string array_size)
    {

        this->array_size=array_size;

    }



    void set_data_type(string data_type)
    {

        this->data_type=data_type;

    }




   void set_info_type(int info_type)
   {

       this->info_type=info_type;

   }




   
   void set_parameter(vector<pair<string,string>> parameter)
   {

       this->parameter=parameter;

   }




    void set_return_type(string data_type)
    {

        this->data_type=data_type;

    }




    // getter methods

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



    string get_array_size()
    {

        return array_size;

    }



    string get_data_type()
    {

        return data_type;

    }




    int get_info_type()
    {

        return info_type;

    }



    
    vector<pair<string,string>> get_parameter()
    {

        return parameter;

    }




    string get_return_type()
    {

        return data_type;

    }



    //other methods

    bool is_array()
    {

        return array_size !="";

    }



    bool is_function()
    {

        return info_type == FUNC_DEC || info_type == FUNC_DEF;

    }



    void add_parameter(string data_type, string parameter_name)
    {

        parameter.push_back({data_type, parameter_name});

    }





    //for assembly

    void set_label(string label){

        this->label = label;

    }



    void set_assembly_name(string assembly_name,bool global_var =false, int array_start=0)
    {
        this->assembly_name = assembly_name;

        this->global_var = global_var;

        this->array_start = array_start;

    }



     void set_array_start(int array_start)
    {

        this->array_start = array_start;

    }
    



    string get_label(){

        return label;

    }

    



    string get_assembly_name(int index){

        if(global_var){

            return assembly_name + "[SI+" + to_string(index)+"]";
            
        }

        int offset = array_start + index*2;
          
        return "[BP-" + to_string(offset)+"]";

    }


    string get_assembly_name()
    {

        return assembly_name;
        
    }


    int get_array_start()
    {

        return array_start;

    }

    

    bool is_global()
    {

        return global_var;

    }



    //friend function

    friend ostream &operator<<(ostream &os, const symbolinfo &obj)
    {

        os << "<" << obj.sym_name << "," << obj.sym_type << ">";

        return os;

    }


};
