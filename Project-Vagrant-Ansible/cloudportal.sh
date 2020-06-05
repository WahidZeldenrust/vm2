printf "\n"
printf "###########################################################################\n"
printf "# Welcome to the cloudportal of VM2 \n"
printf "###########################################################################\n"


cid=0

function newCustomer() {
    echo "Welcome to the cloudportal"
    cd /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/Klanten || exit

    customerAmount="$(ls -1 | wc -l)"
    newID=$( echo "$customerAmount + 1" | bc )

    mkdir $"Klant$newID"
    cd $"Klant$newID"

    cid=$newID

    clear
    echo "Uw klantnummer is "$newID

    environment
}

function existingCustomer() {
    echo "You are a customer"
    echo "What is your customerID?"
    read ID

    cd /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/Klanten/Klant$ID || error
    cid=$ID

    environment

}

function environment() {
    echo "What would you like to do?
(1) Make a test environment  (2) Make a production environment  (3) Remove an environment  (4) Quit"

    read environment

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
      exit
    else
      error
    fi
}


function deleteEnvironment() {


    echo "Which environment would you like to remove?
    (1) production (2) test"

    read delete

    if [ $delete == 1 ]
    then
      cd /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/Klanten/Klant$cid/production || error
      vagrant destroy -f
      cd ..
      rm -rf production
    elif [ $delete == 2 ]
    then
      cd /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/Klanten/Klant$cid/test || error
      vagrant destroy -f
      cd ..
      rm -rf test
    else
      error
    fi

    environment
}

function testEnvironment() {

  cd /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/Klanten/Klant$cid/test || cp -rf /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/test_template /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/Klanten/Klant$cid/test
  cd /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/Klanten/Klant$cid/test || error

  sed -i -e "s/{CUSTOMER_ID}/klant$cid-test-webserver1/g" Vagrantfile
  sed -i -e "s/{ID}/192.168.10$cid.2/g" Vagrantfile
  sed -i -e "s/{CUSTOMER_ID}/klant$cid-test-webserver1/g" inventory.ini
  sed -i -e "s/{ID}/$cid/g" inventory.ini

  vagrant up

  ansible-playbook /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/playbooks/webserver.yml

  environment

}

function productionEnvironment() {

  cd /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/playbooks/ || error
  rm -rf roles
  cp -rf /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/roles_template /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/playbooks/roles

  cd /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/playbooks/roles/database/tasks || error
  sed -i -e "s/{ID}/$cid/g" mysql_config.yml

  cd /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/playbooks/roles/loadbalancer/templates || error
  sed -i -e "s/{ID}/$cid/g" haproxy.cfg.j2
  sed -i -e "s/{CUSTOMER_ID}/klant$cid/g" haproxy.cfg.j2

  cd /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/playbooks/roles/webservers/templates || error
  sed -i -e "s/{ID}/$cid/g" index.php.j2

  cd /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/Klanten/Klant$cid/production || cp -rf /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/prod_template /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/Klanten/Klant$cid/production
  cd /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/Klanten/Klant$cid/production || error

  sed -i -e "s/{CUSTOMER_ID}/klant$cid/g" Vagrantfile
  sed -i -e "s/{ID}/192.168.10$cid./g" Vagrantfile
  sed -i -e "s/{CUSTOMER_ID}/klant$cid/g" inventory.ini
  sed -i -e "s/{ID}/$cid/g" inventory.ini


  vagrant up

  ansible-playbook /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/playbooks/playbook.yml

  environment

#  echo "What name would you like to give your vm?"
#  read vm
}

function error() {
    echo "A error has occured."
    exit
}

function start() {
    echo "Are you an existing customer?
(Y) I am (N) I am a new customer"

read customer


if [ $customer == "Y" ] || [ $customer == "y" ]
then
    existingCustomer
else
    newCustomer
fi
}

start



















#cd Klanten/Klant1/test || exit
#
#vagrant up
#
#
#
#ansible-playbook /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/playbooks/playbook.yml
