#!/bin/bash

echo "*************Table Management System*************"

while true; do
    PS3="Select an operation (1-8): "
    select option in "Create Table" "List Tables" "Drop Table" "Insert Into table" "Select from table" "Delete from table" "Update table" "Exit"
    do
    # numeric validation
    if [[ ! "$REPLY" =~ ^[0-9]+$ ]];
    then
        echo "Invalid input. Numbers only."
        break
    fi

    if [[ "$REPLY" -lt 1 || "$REPLY" -gt 8 ]];
    then
        echo "Invalid choice. Select between 1 and 8."
        break
    fi

        case $REPLY in
1)

        echo "************* Create Table ***********"

        # 1) Read Table Name

        while true;
        do
            echo "Table name must start with a letter and contain only letters, numbers, or underscores"
            read -r -p "enter table name: " table_name

            # check if the input is empty
            if [[ -z "$table_name" ]];
            then
                echo "Table name cannot be empty !!!!"
                continue
            fi

            # name validation
            if [[ ! "$table_name" =~ ^[a-zA-Z][a-zA-Z0-9_]*$ ]];
            then
                echo "Invalid name !!!!"
                continue
            fi
            #check table existance
            if [[ -d "$table_name" ]]
            then
                echo "Table already exists!!!!"
                continue
            fi
            break
        done


        # 2) Read number of Cols
        while true; 
        do
            read -r -p "Enter number of columns: " cols_num

            if [[ ! "$cols_num" =~ ^[1-9][0-9]*$ ]]; then
                echo "Invalid number!!!!"
                continue
            fi

            break
        done

        # Create Table Directory
        if ! mkdir "$table_name" 2>/dev/null; 
        then
            echo "Error creating table directory!"
            continue
        fi


        # 3) Column metadata
        pk_defined=0
        > "$table_name/$table_name.meta"   # create/empty metadata file in table directory

        for (( i=1; i<=cols_num; i++ ));
        do
            echo "-----------------------------------------"
            echo "Column $i"

            # ---- column name ----
            while true;
            do
                read -r -p "Column name: " col_name

                if [[ -z "$col_name" ]];
                then
                    echo "Column name cannot be empty!!!!"
                    continue
                fi

                if [[ ! "$col_name" =~ ^[a-zA-Z][a-zA-Z0-9_]*$ ]];
                then
                    echo "Invalid column name!!!!"
                    continue
                fi

                # prevent duplicate column
                if cut -d':' -f1 "$table_name/$table_name.meta" | grep -qx "$col_name"; 
                then
                    echo "Column name already exists!!!!"
                    continue
                fi

                break
            done

            #  data type
            while true;
            do
                echo "Select Data Type:"
                PS3="Select Data Type (1-2): "
                select option in "int" "string"
                do
                # numeric validation
                if [[ ! "$REPLY" =~ ^[0-9]+$ ]];
                then
                    echo "Invalid input. Numbers only."
                    break
                fi

                if [[ "$REPLY" -lt 1 || "$REPLY" -gt 2 ]];
                then
                    echo "Invalid choice. Select 1 or 2."
                    break
                fi
                case $REPLY in
                    1) data_type="int";;
                    2) data_type="string";;
                    *) echo "Invalid selection!!!!"; continue;;
                esac
                break 2
            done
            done
            PS3="Select an operation (1-8): "

            # primary key
            if [[ $pk_defined -eq 0 ]];
            then
                while true;
                do
                    read -r -p "Is this column a Primary Key? (y/n): " pk_choice

                    if [[ "$pk_choice" =~ ^[Yy]$ ]];
                    then
                    # PK can now be int or string
                    echo "$col_name:$data_type:PK" >> "$table_name/$table_name.meta"
                    pk_defined=1
                    break

                    elif [[ "$pk_choice" =~ ^[Nn]$ ]];
                    then
                        echo "$col_name:$data_type" >> "$table_name/$table_name.meta"
                        break
                    else
                        echo "Please enter y or n !!!!"
                        continue
                    fi
                done
            else
                echo "$col_name:$data_type" >> "$table_name/$table_name.meta"
            fi
        done


        # force PK is exist
        if [[ $pk_defined -eq 0 ]];
        then
            echo "Table must have a Primary Key!!!!"
            rm -r "$table_name" # Remove the directory if creation fails
            continue
        fi


        # create data file inside directory
        touch "$table_name/$table_name.data"
        echo "Table '$table_name' created successfully!"
        read -r -p "Press Enter to continue..."
        break
        ;;
 2)
        echo "************List Tables********"

        # list table directories
        tables=($(ls -d */ 2>/dev/null | sed 's/\/$//'))

        if [ ${#tables[@]} -eq 0 ];
        then
            echo "No tables found in this database."
        else
            echo "Existing tables:"
            echo "--------------------"
            for table in "${tables[@]}";
            do
                echo "$table"
            done
        fi

        read -r -p "Press Enter to continue..."
        break
        ;;
3)
        echo "************Drop Table********"

        # List existing tables (directories)
        tables=($(ls -d */ 2>/dev/null | sed 's/\/$//'))

        # Check if empty
        if [ ${#tables[@]} -eq 0 ];
        then
            echo "No Tables to Drop!!!1"
            read -r -p "Press Enter to continue..."
        else
            # Show tables
            echo "Existing tables:"
            echo "--------------------"
            for i in "${!tables[@]}";
            do
                echo "$((i+1)). ${tables[$i]}"
            done
            echo "0. Back to Table Menu"
            echo "--------------------"

            # ask for selection
            while true;
            do
                read -r -p "Enter table number to drop (enter 0 to cancel): " table_num

                # back option
                if [[ "$table_num" == "0" ]];
                then
                    break
                fi

                # validate number
                if [[ ! "$table_num" =~ ^[0-9]+$ ]] || [ "$table_num" -lt 1 ] || [ "$table_num" -gt "${#tables[@]}" ];
                then
                    echo "Invalid selection!!! Please choose 1-${#tables[@]} or 0 to cancel."
                    continue
                fi

                # get table name
                selected_table="${tables[$((table_num-1))]}"

                # confirmation
                read -r -p "Are you sure you want to delete table '$selected_table'? (y/n): " confirm
                if [[ "$confirm" =~ ^[Yy]$ ]];
                then
                    rm -r "$selected_table"
                    if [ $? -eq 0 ];
                    then
                        echo "Table '$selected_table' deleted successfully!"
                    else
                        echo "Failed to delete table '$selected_table'!!!1"
                    fi
                else
                    echo "Deletion cancelled!!!"
                fi

                break  # exit after one action
            done

            read -r -p "Press Enter to continue..."
        fi
        break
        ;;
4)
        echo "*************** Insert Into Table ***************"

        # List tables
        tables=($(ls -d */ 2>/dev/null | sed 's/\/$//'))

        if [ ${#tables[@]} -eq 0 ]; 
        then
            echo "No tables found to insert into."
            read -r -p "Press Enter to continue..."
        else
            # Show tables
            echo "Existing tables:"
            echo "--------------------"
            for i in "${!tables[@]}";
            do
                echo "$((i+1)). ${tables[$i]}"
            done
            echo "0. Back to Table Menu"
            echo "--------------------"

            # Select table
            while true;
            do
                read -r -p "Enter table number to insert into (0 to cancel): " table_num

                if [[ "$table_num" == "0" ]];
                then
                    break
                fi

                if [[ ! "$table_num" =~ ^[0-9]+$ ]] || [ "$table_num" -lt 1 ] || [ "$table_num" -gt "${#tables[@]}" ];
                then
                    echo "Invalid Selection!!!1"
                    continue
                fi

                selected_table="${tables[$((table_num-1))]}"

                # Read metadata
                columns=($(cut -d':' -f1 "$selected_table/$selected_table.meta"))
                types=($(cut -d':' -f2 "$selected_table/$selected_table.meta"))
                constraints=($(cut -d':' -f3 "$selected_table/$selected_table.meta"))

                # Collect row values
                row_values=()
                for ((i=0; i<${#columns[@]}; i++));
                do
                    col_name="${columns[$i]}"
                    col_type="${types[$i]}"
                    col_constraint="${constraints[$i]}"

                    while true;
                    do
                        read -r -p "Enter value for column '$col_name' ($col_type): " value

                        # empty check
                        if [[ -z "$value" ]];
                        then
                            echo "Value cannot be empty !!!!"
                            continue
                        fi

                        # datatype check
                        if [[ "$col_type" == "int" ]];
                        then
                            if [[ ! "$value" =~ ^[0-9]+$ ]];
                            then
                                echo "Error: Value must be an integer."
                                continue
                            fi
                        fi
                        # vakidate if it was a string
                        if [[ "$col_type" == "string" ]];
                        then
                            if [[ ! $value =~ ^[A-Za-z0-9_.@][A-Za-z0-9_.@\ ]*$ ]]; 
                            then
                                echo "value must be contain only letters or some special chars(' ' , _, @, dot)"
                                continue
                            fi
                        fi

                        value=$(echo "$value" | xargs)  # Trims leading/trailing whitespace

                        # PK uniqueness check
                        if [[ "$col_constraint" == "PK" ]];
                        then
                            if cut -d'|' -f$((i+1)) "$selected_table/$selected_table.data" | grep -qx "$value";
                            then
                                echo "Primary Key '$value' already exists !!!!"
                                continue
                            fi
                        fi

                        row_values+=("$value")
                        break
                    done
                done

                # Save row
                IFS='|'  # field separator
                echo "${row_values[*]}" >> "$selected_table/$selected_table.data"
                unset IFS

                echo "Row inserted successfully into table '$selected_table'."
                read -r -p "Press Enter to continue..."
                break  # back to menu
            done
        fi
        break
        ;;
5)
        echo "********* Select From Table *********"

        # List tables
        tables=($(ls -d */ 2>/dev/null | sed 's/\/$//'))

        if [ ${#tables[@]} -eq 0 ]; 
        then
            echo "No tables found to select from."
            read -r -p "Press Enter to continue..."
        else
            # Show tables
            echo "Existing tables:"
            echo "--------------------"
            for i in "${!tables[@]}";
            do
                echo "$((i+1)). ${tables[$i]}"
            done
            echo "0. Back to Table Menu"
            echo "--------------------"

            # Select table
            while true;
            do
                read -r -p "Enter table number to view (0 to cancel): " table_num

                if [[ "$table_num" == "0" ]];
                then
                    break
                fi

                if [[ ! "$table_num" =~ ^[0-9]+$ ]] || [ "$table_num" -lt 1 ] || [ "$table_num" -gt "${#tables[@]}" ];
                then
                    echo "Error: Invalid selection!"
                    continue
                fi

                selected_table="${tables[$((table_num-1))]}"

                # Ask if all columns or specific
                while true;
                do
                    echo "Select option:"
                    PS3="Select Option (1-2): "
                    select opt in "All columns" "Specific columns"
                    do
                        if [[ ! "$REPLY" =~ ^[0-9]+$ ]];
                        then
                            echo "Invalid input. Numbers only."
                            break
                        fi

                        if [[ "$REPLY" -lt 1 || "$REPLY" -gt 2 ]];
                        then
                            echo "Invalid choice. Select 1 or 2."
                            break
                        fi

                        case $REPLY in
                            1) choice="1";;
                            2) choice="2";;
                        esac
                        break 2
                    done
                done
                PS3="Select an operation (1-8): "

                # Read metadata
                columns=($(cut -d':' -f1 "$selected_table/$selected_table.meta"))

                if [[ "$choice" == "1" ]];
                then
                    # Show header
                    echo "--------------------"
                    echo "${columns[*]}"
                    echo "--------------------"

                    # Show all data
                    if [ -s "$selected_table/$selected_table.data" ]; # -s => if file is not empty
                    then
                        cat "$selected_table/$selected_table.data"
                    else
                        echo "No rows in table!!!1"
                    fi
                elif [[ "$choice" == "2" ]];
                then
                    # print available columns
                    echo "Available columns:"
                    for i in "${!columns[@]}";
                    do
                        echo "$((i+1)). ${columns[$i]}"
                    done

                    # Ask for column nums
                    echo "enter column nums separated by space:"
                    read -r col_input

                    # Validate nums and spaces only, no leading space
                    if [[ ! "$col_input" =~ ^[0-9]+([[:space:]][0-9]+)*$ ]];
                    then
                        echo "Invalid input! Please enter nums separated by spaces"
                        #read -p "Press Enter to continue..."
                        continue
                    fi
                    #debug
                    echo "$col_input"
                    # Convert to array
                # mostafa edit 
                    read -ra selected_indices <<< "$col_input"  

                    # check dublicates
                    unique_cols=($(printf '%s\n' "${selected_indices[@]}" | sort -u)) # sort and retrn unique 
                    if [ ${#selected_indices[@]} -ne ${#unique_cols[@]} ]; then
                        echo "Error: Duplicate column numbers detected!!!!"
                        continue  
                    fi


                    # Validate indices and build selected columns list
                    # selected_indices => array of indices
                    valid=true
                    indexes=()
                    cols_names=()

                    for idx in "${selected_indices[@]}"; 
                    do
                        if [[ "$idx" -lt 1 || "$idx" -gt "${#columns[@]}" ]]; 
                        then
                            echo "Error: Invalid column number '$idx'."
                            valid=false
                        else
                            indexes+=("$idx")                # indicies of selected fields 
                            cols_names+=("${columns[$((idx-1))]}") # get name for header
                        fi
                    done

                    if [[ "$valid" == false ]]; 
                    then
                        continue
                    fi
                    
                    # print header
                    echo "--------------------"
                    echo "${cols_names[*]}"     
                    echo "--------------------"

                    # print data
                    awk -F'|' -v cols="${indexes[*]}" 'BEGIN { n=split(cols, c, " "); OFS="|" } {
                        line=""
                        for (i=1; i<=n; i++) {
                            line = (i==1 ? "" : line OFS) $(c[i])
                        }
                        print line
                    }' "$selected_table/$selected_table.data"

                else
                    echo "Invalid choice!"
                fi

                read -r -p "Press Enter to continue..."
                break  # back to menu
            done
        fi
        break
        ;;
6)
        echo "************ Delete From Table ************"
        
        # List tables
        tables=($(ls -d */ 2>/dev/null | sed 's/\/$//'))

        if [ ${#tables[@]} -eq 0 ]; 
        then
            echo "No tables found."
            read -r -p "Press Enter to continue..."
        else
            # Select table
            while true;
            do
                echo "Existing tables:"
                echo "--------------------"
                for i in "${!tables[@]}";
                do
                    echo "$((i+1)). ${tables[$i]}"
                done
                echo "0. Back to Table Menu"
                echo "--------------------"

                read -r -p "Enter table number to delete from (0 to cancel): " table_num

                if [[ "$table_num" == "0" ]]; then
                    break
                fi

                if [[ ! "$table_num" =~ ^[0-9]+$ ]] || [ "$table_num" -lt 1 ] || [ "$table_num" -gt "${#tables[@]}" ]; then
                    echo "Invalid selection!!!!"
                    continue
                fi
             
                selected_table="${tables[$((table_num-1))]}"
                
                # Identify PK Column Index
                # We need to find which line has PK
                
                pk_line_num=$(grep -n ":PK" "$selected_table/$selected_table.meta" | cut -d: -f1)
                
                if [[ -z "$pk_line_num" ]]; 
                then
                    echo "Table metadata corrupted (note:no PK found)!!!!"
                    break
                fi
                
                # Read PK column name
                pk_col_name=$(sed -n "${pk_line_num}p" "$selected_table/$selected_table.meta" | cut -d: -f1)
                pk_col_type=$(sed -n "${pk_line_num}p" "$selected_table/$selected_table.meta" | cut -d: -f2)
                echo "Table: $selected_table (PK: $pk_col_name)"
                
                read -r -p "Enter Value of PK ($pk_col_name) to delete: " pk_value
                
                if [[ -z "$pk_value" ]]; 
                then
                    echo "value cannot be empty!!!!"
                    continue
                fi

                if [[ "$pk_col_type" == "int" ]]; 
                then
                    if [[ ! "$pk_value" =~ ^[0-9]+$ ]]; 
                    then
                        echo "Error: PK must be an integer!!!!"
                        continue
                    fi
                elif [[ "$pk_col_type" == "string" ]];
                then
                    if [[ ! "$pk_value" =~ ^[A-Za-z0-9_.@][A-Za-z0-9_.@\ ]*$ ]]; 
                    then
                        echo "Error: Invalid string format!!!!"
                        continue
                    fi
                fi

                value=$(echo "$value" | xargs)  # trims whitespace

                # Check if PK exists
                # PK is at index pk_line_num in the data file (1-based index for cut)
                
                if ! cut -d'|' -f"$pk_line_num" "$selected_table/$selected_table.data" | grep -qx "$pk_value"; 
                then
                    echo "Record with PK '$pk_value' not found!!!!"
                    continue
                fi

                # Confirmation
                read -r -p "Are you sure you want to delete the record with $pk_col_name='$pk_value'? (y/n): " confirm
                if [[ ! "$confirm" =~ ^[Yy]$ ]]; 
                then
                    echo "Deletion cancelled!!!!"
                    continue
                fi

                # perform delete using temp file
                # We want to print all lines EXCEPT the one where the PK column matches pk_value
                
                temp_file="$selected_table/delete.tmp"
                data_file="$selected_table/$selected_table.data"
                
                > "$temp_file"  # Create clear temp file in each time 
                # Flags
                deleted=0

                while IFS= read -r line; do
                     # Extract PK from line
                     # We use cut logic here
                     current_pk=$(echo "$line" | cut -d'|' -f"$pk_line_num")
                     
                     if [[ "$current_pk" == "$pk_value" ]]; then
                         deleted=1
                         # Skip writing this line (effectively deleting it)
                     else
                         echo "$line" >> "$temp_file"
                     fi
                done < "$data_file"  # data_file is input for while loop
                
                if [[ $deleted -eq 1 ]]; then
                    # Replace original file content
                    mv "$temp_file" "$data_file"
                    echo "Record deleted successfully!"
                else
                    echo "Something went wrong, record not found during processing!!!"
                    rm -f "$temp_file"
                fi
                
                read -r -p "Press Enter to continue..."
                break
            done
        fi
        break
        ;;
7)
        echo "************ Update Table ************"
        
        # List tables
        tables=($(ls -d */ 2>/dev/null | sed 's/\/$//'))

        if [ ${#tables[@]} -eq 0 ]; 
        then
            echo "No tables found!!!"
            read -r -p "Press Enter to continue..."
        else
            # Select table
            while true;
            do
                echo "Existing tables:"
                echo "--------------------"
                for i in "${!tables[@]}";
                do
                    echo "$((i+1)). ${tables[$i]}"
                done
                echo "0. Back to Table Menu"
                echo "--------------------"

                read -r -p "Enter table number to update (0 to cancel): " table_num

                if [[ "$table_num" == "0" ]]; 
                then
                    break
                fi

                if [[ ! "$table_num" =~ ^[0-9]+$ ]] || [ "$table_num" -lt 1 ] || [ "$table_num" -gt "${#tables[@]}" ]; 
                then
                    echo "Invalid selection!!!!"
                    continue
                fi

                selected_table="${tables[$((table_num-1))]}"
                
                # get PK column index
                pk_line_num=$(grep -n ":PK" "$selected_table/$selected_table.meta" | cut -d: -f1) # get PK column index
                pk_col_name=$(sed -n "${pk_line_num}p" "$selected_table/$selected_table.meta" | cut -d: -f1) # get PK column name
                pk_col_type=$(sed -n "${pk_line_num}p" "$selected_table/$selected_table.meta" | cut -d: -f2)
                echo "Table: $selected_table (PK: $pk_col_name)"
                read -r -p "Enter Value of PK ($pk_col_name) to update: " pk_value

                if [[ -z "$pk_value" ]]; 
                then
                    echo "value cannot be empty!!!!"
                    continue
                fi

                # input Validation
                # allow alphanumeric, space, dot, underscore, dash, 
                if [[ "$pk_col_type" == "int" ]]; 
                    then
                        if [[ ! "$pk_value" =~ ^[0-9]+$ ]]; 
                        then
                            echo "Error: PK must be an integer!!!!"
                            continue
                        fi
                    elif [[ "$pk_col_type" == "string" ]];
                    then
                    if [[ ! "$pk_value" =~ ^[A-Za-z0-9_.@][A-Za-z0-9_.@\ ]*$ ]]; 
                    then
                        echo "Invalid input!!!!"
                        continue
                    fi
                fi

                # Check if PK exists
                if ! cut -d'|' -f"$pk_line_num" "$selected_table/$selected_table.data" | grep -qx "$pk_value"; 
                then
                    echo "Record with PK not found!!!!"
                    continue
                fi
                
                # List Columns to update
                columns=($(cut -d':' -f1 "$selected_table/$selected_table.meta"))  # names of columns that exist
                types=($(cut -d':' -f2 "$selected_table/$selected_table.meta")) # types of all columns
                
                echo "Columns available to update:"
                for i in "${!columns[@]}"; 
                do
                    echo "$((i+1)). ${columns[$i]} ${types[$i]}"
                done
                
                read -r -p "Enter column number to update: " col_num
                
                if [[ ! "$col_num" =~ ^[0-9]+$ ]] || [ "$col_num" -lt 1 ] || [ "$col_num" -gt "${#columns[@]}" ]; 
                then
                    echo "Invalid column selection!!!!"
                    continue
                fi
                
                target_col_idx=$((col_num)) # 1-based index matching meta lines and cut fields
                target_col_name="${columns[$((col_num-1))]}"   # store column name 
                target_col_type="${types[$((col_num-1))]}"   # type of column 
                
                # Prevent updating PK
                if [[ "$target_col_idx" -eq "$pk_line_num" ]]; 
                then
                    echo "Error: Updating Primary Key is not allowed!!!!"
                    continue
                fi
                
                read -r -p "Enter new value for '$target_col_name' ($target_col_type): " new_value
                
                # Validation
                if [[ -z "$new_value" ]]; 
                then
                    echo "Value cannot be empty!!!!"
                    continue
                fi
                #debug
                if [[ "$target_col_type" == "int" ]]; 
                then
                    if [[ ! "$new_value" =~ ^-?[0-9]+$ ]]; 
                    then
                        echo "Value must be an integer!!!!"
                        continue
                    fi
                fi
                if [[ "$target_col_type" == "string" ]];
                        then
                            if [[ ! $new_value =~ ^[A-Za-z0-9_.@][A-Za-z0-9_.@\ ]*$ ]]; 
                            then
                                echo "value must be contain only letters or some special chars(' ' , _, @, dot)"
                                continue
                            fi
                        fi

                
                # Perform Update using Temp File
                temp_file="$selected_table/update.tmp"
                data_file="$selected_table/$selected_table.data"
                updated=0
                

                > "$temp_file"  # Create clear temp file for each time 
                while IFS= read -r line; 
                do
                     current_pk=$(echo "$line" | cut -d'|' -f"$pk_line_num")
                     
                     if [[ "$current_pk" == "$pk_value" ]]; 
                     then
                         # Break line into array
                         IFS='|' read -ra row_arr <<< "$line"
                         # Update specific index
                         row_arr[$((target_col_idx-1))]="$new_value"
                         
                         # Join back to string
                         IFS='|'
                         new_line="${row_arr[*]}"
                         IFS=$' \t\n' # Restore default IFS
                         echo "$new_line" >> "$temp_file"
                         updated=1
                     else
                         echo "$line" >> "$temp_file"
                     fi
                done < "$data_file"
                # Reset IFS for safety if loop exited early (though while read handles it well)
                unset IFS
                
                if [[ $updated -eq 1 ]]; 
                then
                    mv "$temp_file" "$data_file"
                    echo "Record updated successfully."
                else
                    echo "Error: Update failed."
                    rm -f "$temp_file"
                fi
                
                read -r -p "Press Enter to continue..."
                break
            done
        fi        
        break
        ;;
8)
            echo "Returning to Database Menu..."
            return 0
            ;;
*)
            echo "Invalid choice!!! ,Please select a valid option."
            break
            ;;
        esac
    done
done
