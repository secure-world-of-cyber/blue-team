#!/bin/bash


echo "###########################################################################"
echo "########### SCRIPT TO MANAGE USERS ON LINUX SYSTEM !!!!!! #################"
echo "###########################################################################"
echo -e "\n \n \n"


#a function to create users.

create_user(){

read -p "Entrez votre nom d'utilisateur: " username

#verify if the username enterede by the user is empty or no.
while [ -z "$username" ]; do 
     
     read -p "Entrez votre nom d'utilisateur: " username

done      

read -sp "Entrez votre mot de passe: " password

while [ -z "$password" ];do

    read -sp "Entrez votre mot de passe: " password

done

#verify if the password entered by the user is not empty.
if [ -n "$password" ]; then 

    echo -e "\n"

    read -sp "Confirmez votre mot de passe: " password1


    #verify if the two passwords entered by the user are equals or no. 
    if [ "$password" == "$password1" ]; then

     
         #generate a random sha256 hash for the password entered by the user.
         openssl passwd -6 "$password">/tmp/hash_password.txt 2>/dev/null 
         
         #create a the user account with his home directory and shell.
         useradd -m -p $(cat /tmp/hash_password.txt) -s /usr/bin/bash $username

    else

        #if the two passwords entered by the users are different, the username of the account will be deleted from the system and restart the process of account creation.
        sudo userdel -rf $username 2>/dev/null

        echo -e "[!] Désolé, les mot de passe ne correspondent pas, veuillez recommencer le processus, merci !!! \n\n"

        read -p "Voulez-vous recommencer ? O/N: " answer

        if [ $answer == "O" ] || [ $answer == "o" ]; then

            create_user

        else

           exit 1

        fi       

    fi    
      
fi    



if [ $? -eq 0 ];then 
    
    echo -e " \n Compte crée avec succès !!!"

else 

    echo "[!] Une erreur s'est produite. Veuillez réessayer s'il vous plait, merci."

fi         

#userdel -rf $username 2>/dev/null

rm -rf /tmp/hash_password.txt

}

#This function will verify if a user exists on the system.
verify_exist_user()

{

    grep -i $1 /etc/passwd >/dev/null 2>/dev/null
    
    local code_status=$?

    if [ $code_status -ne 0 ]; then

        #echo -e "L'utilisateur que vous avez saisi n'existe pas ! \n"

        return 1
        
    else
       
        #echo -e "[Information] $i exite bien dans le système. \n"

        return 0

    fi    
}

#This function will delete user.
delete_user()
{

  local username=""

  read -p "Entrez le nom d'utilisateur du compte que vous voulez supprimer: " username

  #Verify if the username is empty or no
  while [ -z "$username" ]; do

          read -p "Entrez le nom d'utilisateur du compte que vous voulez supprimer: " username

  done 

    #Verify if the account exist or no
    verify_exist_user "$username"

    # save the returned value of the verify_exist_function.
    local response=$?

  #If the user exist, this if statement will then start the process of deletion his account.
  if [ $response -eq 0 ]; then

     userdel -rf "$username" 2>/dev/null

     echo -e "[***] Utilisateur supprimé avec succès ! \n" 

     exit 0
     
  else

    echo -e "[!] Nous sommes désolé, ce compte n'existe pas,merci. \n"

    exit 1
                
  fi


}


#This fucntion grant administrative privilege to a user.
grant_administrative_privilege_to_user()
{
    local username=""  

    read -p "Entrez le nom de l'utilisateur du compte que vous voulez accorder les privilèges administratives: " username

    while [ -z "$username" ]; do
       
        
        read -p "Entrez le nom de l'utilisateur du compte que vous voulez accorder les privilèges administratives: " username


    done


     verify_exist_user "$username"

     local response=$? 

    #If the user exist, then this if statement will grant to him the administrative privilege.
    if [ $response -eq 0 ]; then

         echo "$username ALL=(ALL:ALL) ALL" >>/etc/sudoers

         echo -e "[***] Succès ! Privilèges administratives attribués. \n"

    else

        echo -e "[!] Nous sommes désolé, ce compte n'existe pas,merci. \n"

        exit 1
        

    fi

    exit 0

}


#This function is the main() function of our bash script. It's the same main function like in aother programming languages.
main()
{

    #This if statement will verify if this script has been executed with root privilege or no.
    if [ $EUID -ne 0 ]; then
         
         echo -e "[Warning !] Veuillez exécuter le script en tant que root avec la commande sudo."

         exit 1

    fi

  #Here, the administrator who will execute this script has the choice what he wants to do.
  echo -e "******************** FAITES VOTRE CHOIX CHER ADMINISTRATEUR ******************* \n \n"  

  echo -e "\n \n 1) Créer un utilisateur. 2) Donner des privilèges administratives à un utilisateur. 3) Supprimer un utilisateur."

  read choice


  # Depending on what the administrator chooses, this case statement will start the process of the task.
  case "$choice" in
  
    1)
        read -p "Combien d'utilisateur voulez-vous créer ? " nb_user

        while [ $nb_user -eq 0 ]; do
     
        echo -e "\n [Warning]: Spécifier un nombre positif différent de zéro s'il vous plait ! \n"

        read -p "Combien d'utilisateur voulez-vous créer ? " nb_user

        done     
      
        if [ $nb_user -ne 0 ];then
   
             for((i=1;i<= $nb_user;i++)); do

               echo -e "\n [***] Création de l'utilisateur numéro $i: \n"

               create_user

             done
     

        fi
    ;;

    2)

       grant_administrative_privilege_to_user

    ;;   
    
    3)

         delete_user

    ;;

    *)
        echo -e "\n [Warning !] Veuillez choisir 1 ou 2 ou 3 selon vos besoins !!! \n"

        main
    ;;
  esac
  

}


#We call the main() function to run the bash script.
main