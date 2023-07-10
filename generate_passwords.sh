#!/bin/bash

greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

function ctrl_c(){
 echo -e "\n\n${redColour}[!] Saliendo...${endColour}\n"
 exit 1 
}

trap ctrl_c INT

echo -e "${greenColour}\n+ - - - - - - - - - - - - - - - - - - - - - - - - - +${endColour}"
echo -e "${greenColour}| By: DsRojo1155                                    |${endColour}"
echo -e "${greenColour}| Lenguaje:Bash                                     |${endColour}"
echo -e "${greenColour}+ - - - - - - - - - - - - - - - - - - - - - - - - - +${endColour}"
function helpPanel(){
 echo -e "\n\n${yellowColour}[+]${endColour}${grayColour} Uso $0${endColour}\n"
 echo -e "\t${greenColour}g)${endColour}${grayColour}Generar contraseñas aleatorias${endColour}"
 echo -e "\t${greenColour}a)${endColour}${grayColour}Almacenar contraseñas en un archivo${endColour}"
 echo -e "\t${greenColour}d)${endColour}${grayColour}Desencriptar archivo de contraseñas${endColour}"
 echo -e "\t${greenColour}e)${endColour}${grayColour}Eliminar una contraseña en base al usuario o correo${endColour}"
 echo -e "\t${greenColour}h)${endColour}${grayColour}Mostrar el panel de ayuda${endColour}"
}


function generate_password(){
 echo -ne "${yellowColour}[+]${endColour}${grayColour}¿Cuanto sera la longitud de las contraseña:${endColour} " && read  length
 characters=$(echo $(echo {a..z} {A..Z} '@%^&*()' {0..9} '@%^&*()') | tr -d ' ')  
 password="" 
 sleep 1
 for ((i = 0; i < $length; i++)); do
   random_index=$((RANDOM % ${#characters}))
   password+=${characters:random_index:1}
 done
 echo -e "${yellowColour}[+]${endColour}${grayColour}Contraseña generada: $password${endColour}"
}

function add_password(){
 file=$1
 echo -ne "${yellowColour}[+]${endColour}${grayColour}¿Cuantas contraseñas necesita guardar ? -->${endColour} " && read number_password 
 touch /root/.$file
 chmod 600 /root/.$file
 for ((i=0; i < $number_password; i++)); do
 
   echo -ne "${yellowColour}[+]${endColour}${grayColour}Ingrese nombre de usuario o correo -->${endColour} " 
   read user
 
   echo -ne "${yellowColour}[+]${endColour}${grayColour}Ingrese la contraseña -->${endColour} " 
   read password
   registro="$user:$password"
   echo $registro >> /root/.$file
   echo "";
 
 done
 echo -e "${yellowColour}[+]${endColour}${grayColour}Contraseñas guardadas correctamente en el archivo file_password.txt${endColour}"
 echo -e "${yellowColour}[+]${endColour}${greenColour}Encryptando archivo para mayor seguridad..${endColour}"
 sleep 1
 key_encryption=$(openssl rand -hex 32) 
 echo -e "${yellowColour}[+]${endColour}${grayColour}Clave generada: $key_encryption${endColour}"
 openssl enc -aes-256-cbc -salt -in /root/.$file -out file_password.enc -pass "pass:$key_encryption" -pbkdf2
 echo -e "${yellowColour}[+]${endColour}${greenColour}Contraseñas guardadas correctamente en el archivo: /root/.$file${endColour}"
 echo -e "${yellowColour}[+]${endColour}${greenColour}Archivo encriptado como: file_password.enc${endColour}"

}

function decrypt_file(){
 key=$1
 echo -ne "${yellowColour}[+]${endColour}${grayColour}Ingrese el nombre del archivo de las contraseñas encriptadas:${endColour}"
 read file
 openssl enc -aes-256-cbc -d -in $file -out file_password_decrypted.txt -pass "pass:$key" -pbkdf2
 echo -e "${yellowColour}[+]${endColour}${grayColour}Desencriptando el archivo con las contraseñas..${endColour}"
 sleep 1 
 echo -e "${yellowColour}[+]${endColour}${grayColour}Archivo desencriptado: file_password_decrypted.txt${endColour}"

}

function delete_password(){
 user=$1
 echo -ne "${yellowColour}[+]${endColour}${grayColour}¿Cual es el nombre del archivo con el que create tu archivo de contraseñas: ${endColour} "
 read file
 echo -e "${yellowColour}[+]${endColour}${grayColour}Eliminando  contraseña de $user${endColour}"
 sleep 1
 cat /root/.$file | grep -v $user | sponge /root/.$file
 key_encryption=$(openssl rand -hex 32)
 openssl enc -aes-256-cbc -salt -in /root/.$file -out file_password.enc -pass "pass:$key_encryption" -pbkdf2
 echo -e "${yellowColour}[+]${endColour}${grayColour}Cambio guardado: /root/.$file${endColour}"
 sleep 1
 echo -e "${yellowColour}[+]${endColour}${grayColour}Archivo nuevo encriptado: file_password.enc${endColour}"
 echo -e "${yellowColour}[+]${endColour}${grayColour}Clave nueva: $key_encryption${endColour}"
}

declare -i parameter_counter=0;

while getopts "ga:d:e:h" arg; do
  case $arg in
   g) let parameter_counter+=1;;
   a) file="$OPTARG"; let parameter_counter+=2;;
   d) key="$OPTARG"; let parameter_counter+=3;;
   e) user="$OPTARG"; let parameter_counter+=4;;
  esac
done

if [ $parameter_counter -eq 1 ]; then
   generate_password
elif [ $parameter_counter -eq 2 ]; then
   add_password $file
elif [ $parameter_counter -eq 3 ]; then
    decrypt_file  $key
elif [ $parameter_counter -eq 4 ]; then
     delete_password $user
else
   helpPanel
fi
