#!/usr/bin/bash

# declare variables
db_dir="./database"
current_db=""
table_dir=""
column_names=""
total=""    #total da tany satr fel meta data it contains asamy el columns 
display_menu(){
echo "1) Create Database"
echo "2) List Database"
echo "3) connect Database"
echo "4) Drop Database"
echo "5) Exit Database"
}
display_database_menu(){
echo "Database $current_db Menu:"
echo "1) Create Table"
echo "2) List Tables"
echo "3) Drop Table"
echo "4) Insert Into Table"
echo "5) Select From Table"
echo "6) Delete From Table"
echo "7) Update Table"
echo "8) disconnect"
}

select_menu(){
echo "1) By Id"
}

drop_database(){
           read -p "Enter the name of the database to drop: " db_name
           if [ -d "$db_dir/$db_name" ]; then
              rm -r "$db_dir/$db_name"
               echo "database named $db_name dropped successfully"
           else
               echo "database $db_name  not found"

 
           fi
               }
 create_table(){
    read -p "Enter table name: " table_name
    table_dir="$db_dir/$db_name/tables"
    touch "$table_dir/$table_name"

    read -p "Enter the number of columns: " num_columns
    while ! [[ $num_columns =~ ^[0-9]+$ ]]; do
        read -p "Please enter a valid number: " num_columns
    done

    # Loop over number of columns and ask user for name and type of each column
    column_names="id:integer"
    for ((i=1;i<=num_columns;i++)); do
        read -p "Enter the name of column $i: " name
        read -p "Enter the type of column $i (string/integer): " type

        # Only allow 'string' or 'integer' to be entered
        while ! [[ "$type" =~ ^(string|integer)$ ]]; do
            read -p "Please enter a valid type (string/integer): " type
        done

        column_names="$column_names, $name:$type"
        total="$total$name," 
    done

    # Write the column names and types to the table file
    echo "$column_names" >> "$table_dir/$table_name"
    # Remove trailing comma from values string
      total="${total%,}"
 
    echo "$total" >>"$table_dir/$table_name" 
    echo "$table_name has been created successfully"
    echo "$table_name has $((num_columns + 1)) columns and the first column is called id and it is the primary key"
}

drop_table(){
list_tables
while true; do
read -p "ENter name of table you want to delete: " name

if [ -f "$table_dir/$name" ]; then
   rm "$table_dir/$name"
   echo "Table $name has been deleted"
   break

 else 
    echo"Table $name is not found"
fi
done
}
insert_to_table(){
    read -p "Enter table name: " table_name
    table_file="$table_dir/$table_name"

    # Check if table exists
    if [ ! -f "$table_file" ]; then
        echo "Table $table_name does not exist"
        return 1
    fi
	# Read the last id from the table file
    last_id=$(tail -n 1 "$table_file" | cut -d',' -f1)
    if [ -z "$last_id" ]; then
        last_id=0
    fi
# Read the second line of the file into an array
first_line=$(sed -n '1p' "$table_file")
second_line=$(sed -n '2p' "$table_file")
fields_excluding_first_field=$(echo "$first_line" | cut -d',' -f2-)





# Replace commas with newline characters and count the number of lines
num_columns=$(echo "$second_line" | tr -cd ',' | wc -c)

# Increment the last id and use it for the new row
    new_id=$((last_id + 1))
    values="$new_id,"

    
while true; do
  values=""
  for (( i=1; i<=($num_columns+1); i++ )); do
    col_name=$(echo "$second_line" | cut -d',' -f $i)
    type=$(echo "$fields_excluding_first_field" | cut -d ',' -f $i | cut -d ':' -f 2)
    while true; do
      read -p "Enter value of column $col_name Type=$type: " value
      if [[ $type == "string" ]] && [[ "$value" =~ ^[[:alpha:]]+$ ]]; then
        values="$values$value,"
        break
      elif [[ $type == "integer" ]] && [[ "$value" =~ ^[0-9]+$ ]]; then
        values="$values$value,"
        break
      else
        echo "Wrong input. Please enter a value of type $type."
      fi
    done
  done
# Add the ID field value to the beginning of the values string
        values="$new_id,$values"

  echo "Record added successfully."
  break
done

# Remove trailing comma from values string
values="${values%,}"
echo "$values" >> "$table_file"

}

list_tables(){
ls $table_dir

}

delete_from_table(){

list_tables

read -p "Enter the name of the table you want to delete from" name

# Check if table exists
    if [ ! -f "$table_dir/$name" ]; then
        echo "Table $name does not exist"
        return 1
    fi
table_file="$table_dir/$name"


select_menu

read -p "enter your choice: " option
            case $option in

                1)
                     while true; do
                      read -p "Enter the id of the row you want to delete: " id
                      # Find the row with the given id and print all fields
                      result=$(awk -v id="$id" -F ',' '$1==id {print}' "$table_file")
                       if [ -z "$result" ]; then
                        echo "ID not found, please enter a valid ID."
                      else
                        sed -i "/^$id,/d" "$table_file" 
                        break
                       fi
                       done
                       ;;
                esac







}

update_table(){


list_tables

read -p "Enter the name of the table you want to update from" name

# Check if table exists
    if [ ! -f "$table_dir/$name" ]; then
        echo "Table $name does not exist"
        return 1
    fi
table_file="$table_dir/$name"


first_line=$(sed -n '1p' "$table_file")


select_menu

read -p "enter your choice: " option
            case $option in

                1) 
                     while true; do
                      read -p "Enter the id of the row you want to select: " id_given_by_user
                      # Find the row with the given id and print all fields
                      result=$(awk -v id="$id_given_by_user" -F ',' '$1==id {print}' "$table_file")
                       if [ -z "$result" ]; then
                        echo "ID not found, please enter a valid ID."
                      else
                       echo "$first_line"
                       echo "$result"
                       break 
                            fi
                       done             

  read -p "Enter the new value : " new_value
  read -p "Enter the field number : " field_number

            echo "$new_value"
            echo "$field_number"
            old_value=$(echo "$result" | cut -d "," -f $field_number) 
            new_result=$(echo "$result" | sed "s/$old_value/$new_value/")
            echo "$new_result" 
         
            line_number=$(grep -n "$result" $table_file | cut -d ":" -f 1)
             sed -i "${line_number}s/.*/$new_result/" $table_file

esac


}













































select_from_table(){
echo "list of all tables"
ls $table_dir    #list tables
read -p "plese enter table name: " table_name
# Check if table exists
    if [ ! -f "$table_dir/$table_name" ]; then
        echo "Table $table_name does not exist"
        return 1
    fi
  echo "$table_name" 
table_file="$table_dir/$table_name"

first_line=$(sed -n '1p' "$table_file")


select_menu

read -p "enter your choice: " option
            case $option in
            
                1)  
                     while true; do 
                      read -p "Enter the id of the row you want to select: " id_given_by_user 
                      # Find the row with the given id and print all fields
                      result=$(awk -v id="$id_given_by_user" -F ',' '$1==id {print}' "$table_file") 
                       if [ -z "$result" ]; then
                        echo "ID not found, please enter a valid ID."
                      else
                       echo "$first_line" 
                       echo "$result"
                       break  
                       fi 
                       done 
                       ;;
                esac
                 
}







connect_to_database(){
    read -p "Enter the name of the database to connect to: " db_name
    if [ -d "$db_dir/$db_name" ]; then
        current_db="$db_name"
        table_dir="$db_dir/$db_name/tables"
        mkdir -p "$table_dir"
        echo "Connected to database $db_name."
        while true; do
            display_database_menu
            read -p "enter your choice: " option
            case $option in
                1)
	            create_table		
                    ;;
                2)
                    list_tables 
                    ;;
                3)  
                    drop_table
                    ;;
                4)
		    insert_to_table
                    ;;
                5)  
                    select_from_table
                    ;;
                6)
                    delete_from_table 
                    ;;
                7)
                    update_table 
                    ;;
		8)
	            current_db=""
                    table_dir=""
                    echo "Disconnected from database."
                    break
                    ;;	
            esac
        done
    else
        echo "database $db_name not found"
    fi
}

while true; do
    display_menu
    read -p "enter your choice: " choice

    case $choice in
        1)
            read -p "enter name of the database: " name
            mkdir -p "$db_dir/$name"
            echo "Database $name created Successfully"
            ;;
        2)
            ls $db_dir
            ;;
        3)
            connect_to_database
            ;;
        4)
            drop_database
            ;;
        5)
            exit 0
            ;;
        *)
            echo "Invalid option."
            ;;
    esac
done



