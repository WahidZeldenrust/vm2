printf "\n"
printf "###########################################################################\n"
printf "# Welkom bij de cloudportaal van VM2 \n"
printf "###########################################################################\n"

cd Klanten/Klant1/Test || exit

vagrant up

ssh-keyscan klant1-Test-webserver01 192.168.33.10 >> ~/.ssh/known_hosts
ssh-keyscan klant1-Test-webserver02 192.168.33.11 >> ~/.ssh/known_hosts
ssh-keyscan klant1-Test-loadbalancer 192.168.33.12 >> ~/.ssh/known_hosts
ssh-keyscan klant1-Test-database 192.168.33.13 >> ~/.ssh/known_hosts

ansible-playbook ~/Documents/vm2/Project-Vagrant-Ansible/playbooks/playbook.yml