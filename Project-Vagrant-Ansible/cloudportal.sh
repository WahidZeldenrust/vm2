printf "\n"
printf "###########################################################################\n"
printf "# Welkom bij de cloudportaal van VM2 \n"
printf "###########################################################################\n"

cd Klanten/Klant1/Test || exit

vagrant up
ansible-playbook /media/vagrant/VM2/VM2/Project-Vagrant-Ansible/playbooks/playbook.yml