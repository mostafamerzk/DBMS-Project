#!/bin/bash

DB_dir="databases"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # store the absolute bath of script locaton

# create databases directory if it not exist
if [ ! -d "$DB_dir" ]; then
    mkdir  "$DB_dir"
    echo "Main databases directory has been created successfuly"
fi

# if exist => ok 

while true;do
    PS3="Select an operation (1-5): "
        select option in "Create Database" "List Databases" "Connect to Database" "Delete Database" "Exit"; do

            case $REPLY in
                 # Create Database
                1) 
                    echo "========================================="
                    echo "          CREATE DATABASE"
                    echo "========================================="
                    while true; do
                        echo "Enter database name: "
                        read -r db_name
                        
                        

    #check if name is empty
                        if [[ -z "$db_name" ]]; then
                            echo "Error: Database name cannot be empty!"
                            continue
                        fi
    #check if database exists
                        if [ -d "$DB_dir/$db_name" ]; then
                            echo "Error: Database '$db_name' already exists!"
                            continue
                        fi
    # Check for special characters
                        if [[ "$db_name" =~ [^a-zA-Z0-9_] ]]; then
                            echo "Error: Database name can only contain letters, numbers, and underscores!"
                            continue
                        fi
                        
    # Check if starts with number
                        if [[ "$db_name" =~ ^[0-9] ]]; then
                            echo "Error: Database name cannot start with a number!"
                            continue
                        fi
    # check length of db name 
                        if [ ${#db_name} -gt 255 ]; then
                            echo "Error: Database name too long (max 255 characters)!"
                            continue
                        fi

    # if skip all above 
    # create database directory

                        mkdir -p "$DB_dir/$db_name"
                        
                        # Set permissions
                        chmod 770 "$DB_dir/$db_name"
                        
    # if creation process doesn't return any thing , creation is ok

                        if [ $? -eq 0 ]; then
                            echo "Database '$db_name' created successfully!"
                        else
                            echo "Error: Failed to create database!"
                        fi
                        break    #break while of creation
                    done
                    read -r -p "Press Enter to continue..."
                    break
                    ;;
                
                  # list databases
                2)
                    echo "========================================="
                    echo "          Existed Databases"
                    echo "========================================="
                    
    #check if directory is empty
                    if [ -z "$(ls -A "$DB_dir")" ]; then
                        echo "No databases found."
                    else
                        ls -1 "$DB_dir"
                    fi
                    
                    read -r -p "Press Enter to continue..."
                    break
                    ;;
                
                  # Connect to Database
                3)
                    echo "========================================="
                    echo "          CONNECT TO DATABASE"
                    echo "========================================="
                    
                    dbs=($(ls -1 "$DB_dir" 2>/dev/null))

                    if [ ${#dbs[@]} -eq 0 ]; then
                        echo "No databases found to connect to."
                        read -r -p "Press Enter to continue..."
                        break
                    fi
                    echo "Available Databases:"
                    echo "--------------------"
                    for i in "${!dbs[@]}"; do
                        echo "$((i+1)). ${dbs[$i]}"
                    done
                    echo "0. Back to Main Menu"
                    echo "--------------------"

                    while true; do
                        read -r -p "Enter database number to connect to: " db_num
                        
                        if [[ "$db_num" == "0" ]]; then
                            break
                        fi

                        if [[ ! "$db_num" =~ ^[0-9]+$ ]] || [ "$db_num" -lt 1 ] || [ "$db_num" -gt "${#dbs[@]}" ]; then
                            echo "Error: Invalid selection!"
                            continue
                        fi

                        selected_db="${dbs[$((db_num-1))]}"
                        
                     # Connect
                        echo "Connecting to '$selected_db'..."

    # Verify we can enter the directory

                        if cd "$DB_dir/$selected_db" 2>/dev/null; then
                            echo "Connected successfully!"
                            
                            # Source table.sh

                            if [ -f "$SCRIPT_DIR/table.sh" ]; then
                                source "$SCRIPT_DIR/table.sh"
                            else
                                echo "Error: table.sh script not found at $SCRIPT_DIR/table.sh"
                            fi
                            
                        # Return to root after table operations
                            cd "$SCRIPT_DIR"
                            echo "Disconnected from '$selected_db'."
                        else
                             echo "Error: Could not access database directory '$DB_dir/$selected_db'."
                        fi
                        break 
                    done
                    read -r -p "Press Enter to continue..." 
                    break
                    ;;

                  # DELETE DATABASE WITH NUMBERED SELECTION
                4)
                echo "========================================="
                echo "          DELETE DATABASE"
                echo "========================================="
                
                while true; do
    #store of existed databases
                    dbs=($(ls -1 "$DB_dir" 2>/dev/null)) 
                    
    # 2. Check if any databases exist
                    if [ ${#dbs[@]} -eq 0 ]; then
                        echo "No databases available to delete."
                        break                       #return to main menu
                    fi
                    
    # databases with numbers
                    echo "Existed databases:"
                    echo "--------------------"
                    for i in "${!dbs[@]}"; do
                        echo "$((i+1)). ${dbs[$i]}"
                    done
                    echo "0. Back to Main Menu" # if he don't want to delete
                    echo "--------------------"
                    
    # select a num to delete
                    read -r -p "Enter database number to delete: " db_num
                    
    #back option to main menu
                    if [[ "$db_num" == "0" ]]; then
                        break
                    fi

    #validate input is a number and within range

                    if [[ ! "$db_num" =~ ^[0-9]+$ ]] || [ "$db_num" -lt 1 ] || [ "$db_num" -gt "${#dbs[@]}" ]; then
                        echo "Error: Invalid selection! Please select 1-${#dbs[@]}"
                        read -r -p "Press Enter to try again..."
                        clear                       # Keeps the terminal clean
                        continue
                    fi
                    
    #get selected database name
                    selected_db="${dbs[$((db_num-1))]}"
                    
    #Confirmation
                    echo "========================================="
                    read -r -p "Are you sure you want to delete database '$selected_db'? (y/n): " ans
                    
                    if [[ "$ans" =~ ^[Yy]$ ]]; then
                        rm -r "$DB_dir/$selected_db"
                        if [ $? -eq 0 ]; then
                            echo "Database '$selected_db' deleted successfully!"
                        else
                            echo "Error: Failed to delete database!"
                        fi
                    else
                        echo "Deletion cancelled."
                    fi 
                    
                    break #exit the while after one action (success or cancel) and return to main
                done        # done of while 
                
                read -r -p "Press Enter to continue..."
                break
                ;;

                  # Exit
                5)
                    echo "========================================="
                    echo "Thank you for using Bash DBMS!"
                    echo "Exiting..."
                    echo "========================================="
                    exit 0
                    ;;
                    
                *)
                    echo "Invalid option. Please select 1-5."
                    break
                    ;;
            esac
        done
    done