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

    createEnvironment

}



function existingCustomer() {
    echo "You are a customer"
    echo "What is your customerID?"
    read ID

    cd /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/Klanten/Klant$ID/Test || idError

    environment

}

function deleteEnvironment() {
    echo "remove"
}

function testEnvironment() {

  cp -rf /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/template_omgeving /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/Klanten/Klant$cid/Test

}

function createEnvironment() {
    echo "What would you like to do?
(1) Make a test environment  (2) Make a production environment  (3) Remove an environment"

    read environment

    if [ $environment == 1 ]
    then
      testEnvironment
    else

      vagrant up
      ansible-playbook /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/playbooks/playbook.yml
    fi
}

function idError() {
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




#cd Klanten/Klant1/Test || exit
#
#vagrant up
#
#
#
#ansible-playbook /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/playbooks/playbook.yml
