printf "\n"
printf "###########################################################################\n"
printf "# Welcome to the cloudportaal of VM2 \n"
printf "###########################################################################\n"


echo "Are you an existing customer?
(Y) I am (N) I am a new customer"

read customer
if [ $customer == "Y" ]
then
    echo "You are a customer"
else
    echo "You are not a customer"
fi

#cd Klanten/Klant1/Test || exit
#
#vagrant up
#
#
#
#ansible-playbook /media/vagrant/vm2/vm/vm2/Project-Vagrant-Ansible/playbooks/playbook.yml
