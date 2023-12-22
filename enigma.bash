#! /usr/bin/env bash

function pushAsciiCode() {
    code=$1
    key=$2
    pushed=$(( code+key ))
    if [[ $pushed -gt 90 ]]; then
        pushed=$(( code-90 ))
        pushed=$(( pushed+key ))
        pushed=$(( pushed%25 ))
        pushed=$(( pushed+64 ))
    fi
    echo $pushed
}

function encrypt() {
    letter=$1
    key=$2
    ascii_value=$(printf "%d" "'$letter")
    ascii_value=$(pushAsciiCode $ascii_value $key)
    echo $(printf "\x$(printf %x "$ascii_value")")
}

function pullAsciiCode() {
    code=$1
    key=$2
    pulled=$(( code-key ))
    if [[ $pulled -lt 65 ]]; then
        AToCode=$(( code-65 ))
        key=$(( key-AToCode ))
        pulled=$(( 91-key ))
    fi
    echo $pulled
}

function decrypt() {
    letter=$1
    key=$2
    ascii_value=$(printf "%d" "'$letter")
    ascii_value=$(pullAsciiCode $ascii_value $key)
    echo $(printf "\x$(printf %x "$ascii_value")")
}

function encryptMessage() {
    message=$1
    key=$2
    
    encrypted_message=""
    length=${#message}
    for ((i = 0; i < length; i++)); do
        letter="${message:i:1}"
        if [[ $letter = " " ]]; then
            encrypted_message+=" "
            continue
        fi
        encrypted_letter=$(encrypt "$letter" "$key")
        encrypted_message+=$encrypted_letter
    done
    echo $encrypted_message
}

function decryptMessage() {
    message=$1
    key=$2
    
    decrypted_message=""
    length=${#message}
    for ((i = 0; i < length; i++)); do
        letter="${message:i:1}"
        if [[ $letter = " " ]]; then
            decrypted_message+=" "
            continue
        fi
        decrypted_letter=$(decrypt "$letter" "$key")
        decrypted_message+=$decrypted_letter
    done
    echo $decrypted_message
}

function createFile() {
    message_regex='^[A-Z ]+$'
    filename_regex='^[A-Za-z]+.[A-Za-z]+$'
    echo "Enter the filename:"
    read -r filename
    
    while [[ true ]]
    do
        if [[ !("$filename" =~ $filename_regex) ]]; then
            echo "File name can contain letters and dots only!"
            return
        fi
        break
    done
    
    echo "Enter a message:"
    read -r message
    
    while [[ true ]]
    do
        if [[ !("$message" =~ $message_regex) ]]; then
            echo "This is not a valid message!"
            return
        fi
        break
    done
    
    echo "$message" > "$filename"
    echo "The file was created successfully!"
}

function readFile() {
    filename_regex='^[A-Za-z]+.[A-Za-z]+$'
    echo "Enter the filename:"
    read -r filename
    
    while [[ true ]]
    do
        if [[ !( -e "$filename" ) ]]; then
            echo "File not found!"
            return
        fi
        break
    done
    echo "File content:"
    head "$filename"
}

function encryptFile() {
    filename_regex='^[A-Za-z]+.[A-Za-z]+$'
    echo "Enter the filename:"
    read -r filename
    
    while [[ true ]]
    do
        if [[ !( -e "$filename" ) ]]; then
            echo "File not found!"
            return
        fi
        break
    done
    
    echo "Enter password:"
    read -r password
    
    # while [[ true ]]
    #   do
    #     if [[ !( -e "$password" ) ]]; then
    #       echo "File not found!"
    #       return
    #     fi
    #     break
    #   done
    
    openssl enc -aes-256-cbc -e -pbkdf2 -nosalt -in "$filename" -out "$filename.enc" -pass pass:"$password" &>/dev/null
    exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        echo "Fail"
        return
    else
        rm "$filename"
        echo "Success"
    fi
}

function decryptFile() {
    filename_regex='^[A-Za-z]+.[A-Za-z]+$'
    echo "Enter the filename:"
    read -r filename
    
    while [[ true ]]
    do
        if [[ !( -e "$filename" ) ]]; then
            echo "File not found!"
            return
        fi
        break
    done
    
    echo "Enter password:"
    read -r password
    
    # while [[ true ]]
    #   do
    #     if [[ !( -e "$password" ) ]]; then
    #       echo "File not found!"
    #       return
    #     fi
    #     break
    #   done
    
    M=${#filename}
    N=$(( M-4 ))
    outputFile=$(echo $( echo "$filename" | cut -c 1-$N ))
    openssl enc -aes-256-cbc -d -pbkdf2 -nosalt -in "$filename" -out "$outputFile" -pass pass:"$password" &>/dev/null
    exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        echo "Fail"
    else
        rm "$filename"
        echo "Success"
    fi
    return
}

function menu() {
    echo "Welcome to the Enigma!"
    while [[ true ]]
    do
        echo  "0. Exit"
        echo  "1. Create a file"
        echo  "2. Read a file"
        echo  "3. Encrypt a file"
        echo  "4. Decrypt a file"
        echo  "Enter an option:"
        
        read -r command
        case $command in
            "0" )
                echo "See you later!"
                exit
            break;;
            "1" )
                createFile
                echo
            continue;;
            "2" )
                readFile
                echo
            continue;;
            "3" )
                encryptFile
                echo
            continue;;
            "4" )
                decryptFile
                echo
            continue;;
            * )
                echo "Invalid option!"
            continue;;
        esac
    done
}


menu