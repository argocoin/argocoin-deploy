#!/bin/sh

# Error if variable is unassigned
set -u

user='tec'

# Prompt to continue
# http://stackoverflow.com/questions/3231804/in-bash-how-to-add-are-you-sure-y-n-to-any-command-or-alias
function prompt_continue() {
	msg="$1 [y/N]"
	response=''
	read -r -p "$msg " response
	case "$response" in
		[yY][eE][sS]|[yY]) 
			;;
		*)
			exit 1
			;;
	esac
}

# Turn off automatic updates
function turn_off_automatic_updates() {
	echo
	echo "*** Turning off automatic updates for user $user"
	echo
	automaticUpdates=$(su -c 'gsettings get org.gnome.software download-updates' $user)
	if [[ "$automaticUpdates" =~ false ]]; then
		echo "Automatic updates are off for user $user"
		return 0
	fi

	echo "Turning off automatic updates for user $user"

	su -c 'gsettings set org.gnome.software download-updates false' $user
	echo "Restart required..."
	prompt_continue 'Do you want to continue?'
	shutdown -r now
}

# Install EPEL repository
function install_epel_repo() {
	echo
	echo '*** Installing EPEL repo'
	echo
	yum install epel-release
}

# Install Ansible
function install_ansible() {
	echo
	echo '*** Installing ansible'
	echo
	yum install ansible
}

# Check Ansible
function check_ansible() {
	echo
	echo '*** Ansible version'
	echo
	ansible --version
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "There is a problem running ansible ($ret)"
		exit $ret
	fi
}

# Create ssh keypair
function create_ssh_keypair() {
	echo
	echo '*** Create ssh keypair'
	echo
	sshPrivateKey="/home/$user/.ssh/id_rsa"
	if [ -f "$sshPrivateKey" ]; then
		echo "Ssh private key $sshPrivateKey exists"
		return 0
	fi

	su -c 'ssh-keygen' $user
	authorizedKeys="/home/$user/.ssh/authorized_keys"
	rm -f "$authorizedKeys"
}

function copy_ssh_keypair() {
	echo
	echo '*** Copy ssh keypair to localhost'
	echo
	sshPrivateKey="/home/$user/.ssh/id_rsa"
	ssh-copy-id -i "$sshPrivateKey" "$user@localhost"
}

function add_localhost_to_ansible() {
	echo
	echo '*** Add localhost to ansible hosts file'
	echo
	ansibleHosts='/etc/ansible/hosts'
	localhostEntry='localhost'
	# http://stackoverflow.com/questions/3557037/appending-a-line-to-a-file-only-if-it-does-not-already-exist
	grep -q -E "^$localhostEntry" "$ansibleHosts" || echo "$localhostEntry" >> "$ansibleHosts"
}

function run_ansible_ping() {
	echo
	echo '*** Run ansible ping'
	echo
	su -c 'ansible all -m ping' $user
}

turn_off_automatic_updates
install_epel_repo
install_ansible
check_ansible
create_ssh_keypair
copy_ssh_keypair
add_localhost_to_ansible
run_ansible_ping

