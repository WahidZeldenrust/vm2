printf "\n"
printf "###########################################################################\n"
printf "# Welcome to the cloudportal of VM2 \n"
printf "###########################################################################\n"


cid=0

#When the user is a new customer the new cutomer function is called
function newCustomer() {
    echo "Welcome to the cloudportal"
    #The script navigates to the customer map.
    cd /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/Klanten || exit

    #The ammount of customers are counted.
    customerAmount="$(ls -1 | wc -l)"
    #A new customer ID is calculated which isnt in use.
    newID=$( echo "$customerAmount + 1" | bc )

    #The directory gets created and the system navigates to it.
    mkdir $"Klant$newID"
    cd $"Klant$newID"

    #This variable now has the new customer ID.
    cid=$newID

    clear
    echo "Uw klantnummer is "$newID

    environment
}

#When the user is an existing customer the existing cutomer function is called
function existingCustomer() {
    echo "You are a customer"
    echo "What is your customerID?"
    read ID

    #The script navigates to the location of the customer if its available. If it doesnt exist, an error occurs.
    cd /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/Klanten/Klant$ID || errorAccount
    cid=$ID

    environment

}

#When an exisiting user chooses to reroll an environment. The rerollenvironment is called.
function rerollEnvironment() {
    clear

    echo "Which environment would you like to reroll?
    (1) production (2) test"

    read reroll

    #If the user chooses 1, the system will navigate to the producrtion environment. If there is non, an error occurs.
    if [ $reroll == 1 ]
    then
      cd /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/Klanten/Klant$cid/production || error
      vagrant reload
      vagrant up

      #Clean config files are coppied to the roles location.
      cd /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/playbooks/ || error
      rm -rf roles
      cp -rf /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/templates/roles_template /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/playbooks/roles

      #The config files are edited with the right information before deploting the playbook.
      cd /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/playbooks/roles/database/tasks || error
      #In the mysql_config.yml file, the right ip addresses are added for connection allowance.
      sed -i -e "s/{ID}/$cid/g" mysql_config.yml

      #In the haproxy.cfg.j2 file, the right ip addresses for loadbalancing.
      cd /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/playbooks/roles/loadbalancer/templates || error
      sed -i -e "s/{ID}/$cid/g" haproxy.cfg.j2
      sed -i -e "s/{CUSTOMER_ID}/klant$cid/g" haproxy.cfg.j2

      #In the index.php.j2 files the ip address is changed to the right database IP.
      cd /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/playbooks/roles/webservers/templates || error
      sed -i -e "s/{ID}/$cid/g" index.php.j2

      #The script tries to navigate to the right production map, if it does not exist, the prodcuction map is created.
      cd /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/Klanten/Klant$cid/production || cp -rf /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/templates/prod_template /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/Klanten/Klant$cid/production
      #The script tries to navigate to the right production map. If it still doesnt exist an error occurs.
      cd /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/Klanten/Klant$cid/production || error

      #The vagrant and inventory.init files are eddited. The ip adresses of the machines are added and the machine get the right ip address in the right
      #range for the customer. The right machine name is also added.
      sed -i -e "s/{CUSTOMER_ID}/klant$cid/g" Vagrantfile
      sed -i -e "s/{ID}/192.168.10$cid./g" Vagrantfile
      sed -i -e "s/{CUSTOMER_ID}/klant$cid/g" inventory.ini
      sed -i -e "s/{ID}/$cid/g" inventory.ini

      ansible-playbook /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/playbooks/playbook.yml

      environment

    #If the user chooses 2, the system will navigate to the test environment. If there is non, an error occurs.
    elif [ $reroll == 2 ]
    then
      cd /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/Klanten/Klant$cid/test || error
      vagrant reload
      vagrant up

      #The script tries to navigate to the right test map, if it does not exist, the test map is created.
      cd /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/Klanten/Klant$cid/test || cp -rf /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/templates/test_template /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/Klanten/Klant$cid/test
      #The script tries to navigate to the right test map. If it still doesnt exist an error occurs.
      cd /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/Klanten/Klant$cid/test || error

      #The vagrant and inventory.init files are eddited. The ip adresses of the machines are added and the machine get the right ip address in the right
      #range for the customer. The right machine name is also added.
      sed -i -e "s/{CUSTOMER_ID}/klant$cid-test-webserver1/g" Vagrantfile
      sed -i -e "s/{ID}/192.168.10$cid.2/g" Vagrantfile
      sed -i -e "s/{CUSTOMER_ID}/klant$cid-test-webserver1/g" inventory.ini
      sed -i -e "s/{ID}/$cid/g" inventory.ini

      ansible-playbook /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/playbooks/webserver.yml

  environment

    else
      error
    fi

    environment
}

#When an exisiting user chooses to update the test environment. The updateEnvironment function is called.
function updateEnvironment() {
    clear

    echo "Which environment would you like to reconfigure?
    (1) test"

    read reconfigure

    #If the user chooses 1, the script navigates to the right location.
    if [ $reconfigure == 1 ]
    then
        cd /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/Klanten/Klant$cid/test || errorConfig
        rm -rf Vagrantfile
        #A clean vagrantfile is added.
        cp -rf /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/templates/test_template/Vagrantfile /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/Klanten/Klant$cid/test/Vagrantfile

        #The right information is added.
        sed -i -e "s/{CUSTOMER_ID}/klant$cid-test-webserver1/g" Vagrantfile
        sed -i -e "s/{ID}/192.168.10$cid.2/g" Vagrantfile

        echo "What would you like to edit?
        (1) Ram (2) VM Name"
        read edit

        if [ $edit == 1 ]
        then
          ramEdit
        elif [ $edit == 2 ]
        then
          hostnameEdit
        fi
    else
      error
    fi

    environment
}

#This is where the ram gets edited for the test environment.
function ramEdit() {
  echo "How much ram would you like to give in mb? It must be lower than 1024"
          read answer
          if [ $answer -lt 1024 ]
          then
            echo "Would you also like to edit the VM name?
            (1) Yes (2) No"
            read response
            if [ $response == 2 ]
             then
               #De machine shutdown so that the information can be updated.
                vagrant halt
                sed -i -e "s/{RAM}/$answer/g" Vagrantfile
                #System reloads.
                vagrant reload
              elif [ $response == 1 ]
              then
                #De machine shutdown so that the information can be updated.
                vagrant halt
                sed -i -e "s/{RAM}/$answer/g" Vagrantfile
                #The hostnameEdit function is called.
                hostnameEdit
            fi
          else
            error
          fi
    
}

function hostnameEdit() {
    echo "What would you like to name your VM?"
    read name

    echo "Would you also like to edit the ram?
    (1) Yes (2) No"
    read response
    if [ $response == 1 ]
    then
        #De machine shutdown so that the information can be updated.
        vagrant halt
        sed -i -e "s/{HOSTNAME}/$name/g" Vagrantfile

        #The ramEdit function is called.
        ramEdit
    elif [ $response == 2 ]
    then
        #De machine shutdown so that the information can be updated.
        vagrant halt
        sed -i -e "s/{HOSTNAME}/$name/g" Vagrantfile
        #System reloads.
        vagrant reload
    fi



}

#environment is a function that leads the whole script.
function environment() {
    clear
    #this is where a choice is made, what the user wants to do.
    echo "What would you like to do?
(1) Make a test environment  (2) Make a production environment  (3) Remove an environment  (4) Reroll an environment (5) Update an environment (6) Quit"

    read environment

    #Depending on the answer the statements sends the program to the right function.
    if [ $environment == 1 ]
    then
      testEnvironment
    elif [ $environment == 2 ]
    then
      productionEnvironment
    elif [ $environment == 3 ]
    then
      deleteEnvironment
    elif [ $environment == 4 ]
    then
      rerollEnvironment
    elif [ $environment == 5 ]
    then
      updateEnvironment
    elif [ $environment == 6 ]
    then
      exit
    else
      error
    fi
}

#In this function the environment gets removed and deleted.
function deleteEnvironment() {
    clear

    echo "Which environment would you like to remove?
    (1) production (2) test"

    read delete

    if [ $delete == 1 ]
    then
      #After choosing to remove the production. The code navigates to the production map and removes the directory including subdirectories.
      #Vagrant also destroys the machine/machines.
      cd /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/Klanten/Klant$cid/production || error
      vagrant destroy -f
      cd ..
      rm -rf production
    elif [ $delete == 2 ]
    then
      #After choosing to remove the production. The code navigates to the test map and removes the directory including subdirectories.
      #Vagrant also destroys the machine/machines.
      cd /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/Klanten/Klant$cid/test || error
      vagrant destroy -f
      cd ..
      rm -rf test
    else
      error
    fi
    environment
}


#In this function the test environment gets created.
function testEnvironment() {

  clear
  #The script tries to navigate to the right test map, if it does not exist, the test map is created.
  cd /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/Klanten/Klant$cid/test || cp -rf /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/templates/test_template /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/Klanten/Klant$cid/test
  #The script tries to navigate to the right test map, if it still does not exist, an error occurs.
  cd /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/Klanten/Klant$cid/test || error

  #The users ip range and name is added to the vagrant and inventory file.
  sed -i -e "s/{CUSTOMER_ID}/klant$cid-test-webserver1/g" Vagrantfile
  sed -i -e "s/{HOSTNAME}/klant$cid-test-webserver1/g" Vagrantfile
  sed -i -e "s/{ID}/192.168.10$cid.2/g" Vagrantfile
  sed -i -e "s/{CUSTOMER_ID}/klant$cid-test-webserver1/g" inventory.ini
  sed -i -e "s/{ID}/$cid/g" inventory.ini
  sed -i -e "s/{RAM}/512/g" Vagrantfile

  vagrant up

  ansible-playbook /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/playbooks/webserver.yml

  environment

}

#In this function the production environment gets created.
function productionEnvironment() {

  clear

  #Clean config files are coppied to the roles location.
  cd /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/playbooks/ || error
  rm -rf roles
  #The script first makes sure that a clean roles configuration is used.
  cp -rf /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/templates/roles_template /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/playbooks/roles

  #The config files are edited with the right information before deploying the playbook.
  cd /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/playbooks/roles/database/tasks || error
  #In the mysql_config.yml file, the right ip addresses are added for connection allowance.
  sed -i -e "s/{ID}/$cid/g" mysql_config.yml

  #In the haproxy.cfg.j2 file, the right ip addresses for loadbalancing.
  cd /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/playbooks/roles/loadbalancer/templates || error
  sed -i -e "s/{ID}/$cid/g" haproxy.cfg.j2
  sed -i -e "s/{CUSTOMER_ID}/klant$cid/g" haproxy.cfg.j2

  #In the index.php.j2 files the ip address is changed to the right database IP.
  cd /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/playbooks/roles/webservers/templates || error
  sed -i -e "s/{ID}/$cid/g" index.php.j2

  #The script tries to navigate to the right production map, if it does not exist, the prodcuction map is created.
  cd /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/Klanten/Klant$cid/production || cp -rf /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/templates/prod_template /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/Klanten/Klant$cid/production
  #The script tries to navigate to the right production map. If it still doesnt exist an error occurs.
  cd /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/Klanten/Klant$cid/production || error

  #The vagrant and inventory.init files are eddited. The ip adresses of the machines are added and the machine get the right ip address in the right
  #range for the customer. The right machine name is also added.
  sed -i -e "s/{CUSTOMER_ID}/klant$cid/g" Vagrantfile
  sed -i -e "s/{ID}/192.168.10$cid./g" Vagrantfile
  sed -i -e "s/{CUSTOMER_ID}/klant$cid/g" inventory.ini
  sed -i -e "s/{ID}/$cid/g" inventory.ini

  echo "What tier would you like to use for this environment?
  (1) Bronze 60% max cpu usage (2) Silver 70% max cpu usage (3) Gold 80% max cpu usage (4) 100% max cpu usage"

  read answer

  #This section allows the user to choose the capacity of the machines.
  #This limits the cpu usage.
  if [ $answer == 1 ]
  then
    sed -i -e "s/{CAP}/60/g" Vagrantfile
  elif [ $answer == 2 ]
  then
      sed -i -e "s/{CAP}/70/g" Vagrantfile
  elif [ $answer == 3 ]
  then
      sed -i -e "s/{CAP}/80/g" Vagrantfile
  elif [ $answer == 4 ]
  then
      sed -i -e "s/{CAP}/100/g" Vagrantfile
  else
      error
  fi


  vagrant up

  ansible-playbook /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/playbooks/playbook.yml

  environment

}

#This function is called when there is an error.
function error() {
    echo "An error has occured."
    exit
}
#This function is called when there is an error.
function errorAccount() {
    echo "This account does not exist"
    exit
}
#This function is called when there is an error.
function errorConfig() {
    echo "No existing environment available to reconfigure."
    exit
}

#The start functions asks for response.
function start() {
    echo "Are you an existing customer?
(Y) I am (N) I am a new customer"

read customer


if [ $customer == "Y" ] || [ $customer == "y" ]
then
    #If it is an existing customer, the existing customer function is called.
    existingCustomer
else
    #If it isnt an existing customer, the new customer function is called.
    newCustomer
fi
}

#This is where the start function is called.
start