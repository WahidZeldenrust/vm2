printf "\n"
printf "###########################################################################\n"
printf "# Welkom bij de cloudportaal van VM2 \n"
printf "###########################################################################\n"

cd Klanten/Klant1/Test || exit

vagrant up
ansible-playbook playbook.yml