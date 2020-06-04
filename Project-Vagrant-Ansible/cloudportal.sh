printf "\n"
printf "###########################################################################\n"
printf "# Welcome to the cloudportal of VM2 \n"
printf "###########################################################################\n"


function newCustomer() {
    echo "Welcome to the cloudportal"
    cd /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/Klanten || exit

    customerAmount="$(ls -1 | wc -l)"
    newID=$( echo "$customerAmount + 1" | bc )

    mkdir $"Klant$newID"
    cd $"Klant$newID"



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

function createEnvironment() {
    echo "What would you like to make?
(1) Test environment  (2) Production environment"

    read environment

    if [ $environment == 1 ]
    then
      echo "test"
    else

      vagrant up
      ansible-playbook /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/playbooks/playbook.yml
    fi
}

function idError() {
    echo "CustomerID does not exist"
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
