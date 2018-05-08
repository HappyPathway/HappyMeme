sudo apt-get update
sudo apt-get install -y python-pip
sudo pip install -r /tmp/playbooks/requirements.txt
sudo ansible-playbook /tmp/playbooks/app_install.yaml
sudo rm -rf /tmp/playbooks