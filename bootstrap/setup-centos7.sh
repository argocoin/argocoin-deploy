#!/bin/sh

# Error if variable is unassigned
set -u


# Add to sudo
function add_to_sudo() {
	echo
	echo "*** Adding user to sudo"
	echo
	sudo ls /etc >/dev/null
	ret=$?
	if [ $ret -eq 0 ]; then
		echo "Already in sudo"
		return 0
	fi

	echo "Adding user to sudo..."
	su -c "gpasswd -a $USER wheel"

	# https://superuser.com/questions/272061/reload-a-linux-users-group-assignments-without-logging-out
	echo "Restart required..."
	prompt_continue 'Do you want to continue?'
	shutdown -r now
	exit 0
}

# Set Git email
function set_git_email() {
	echo
	echo "*** Setting git user email"
	echo
	gitUserEmail=$(git config --global user.email)
	if [ -n "$gitUserEmail" ]; then
		echo "Git user email already set to $gitUserEmail"
		return 0
	fi
		
	gitUserEmail=''
	read -p 'Enter git user email: ' gitUserEmail
	if [ -z "$gitUserEmail" ]; then
		echo "Not setting git user email"
		return 0
	fi
		
	echo "Setting git user email to $gitUserEmail"
	git config --global user.email "$gitUserEmail"
}

# Set Git name
function set_git_name() {
	echo
	echo "*** Setting git user name"
	echo
	gitUserName=$(git config --global user.name)
	if [ -n "$gitUserName" ]; then
		echo "Git user name already set to $gitUserName"
		return 0
	fi
		
	gitUserName=''
	read -p 'Enter git user name: ' gitUserName
	if [ -z "$gitUserName" ]; then
		echo "Not setting git user name"
		return 0
	fi
		
	echo "Setting git user name to $gitUserName"
	git config --global user.name "$gitUserName"
}


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
	echo "*** Turning off automatic updates"
	echo
	automaticUpdates=$(gsettings get org.gnome.software download-updates)
	if [[ "$automaticUpdates" =~ false ]]; then
		echo "Automatic updates are off"
		return 0
	fi

	echo "Turning off automatic updates"

	gsettings set org.gnome.software download-updates false
	echo "Restart required..."
	prompt_continue 'Do you want to continue?'
	shutdown -r now
	exit 0
}

# Install EPEL repository
function install_epel_repo() {
	echo
	echo '*** Installing EPEL repo'
	echo
	sudo yum install epel-release
}

# Install Ansible
function install_ansible() {
	echo
	echo '*** Installing ansible'
	echo
	sudo yum install ansible
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
	sshPrivateKey="$HOME/.ssh/id_rsa"
	if [ -f "$sshPrivateKey" ]; then
		echo "Ssh private key $sshPrivateKey exists"
		return 0
	fi

	ssh-keygen
	authorizedKeys="$HOME/.ssh/authorized_keys"
	rm -f "$authorizedKeys"
}

function copy_ssh_keypair() {
	echo
	echo '*** Copy ssh keypair to localhost'
	echo
	sshPrivateKey="$HOME/.ssh/id_rsa"
	ssh-copy-id -i "$sshPrivateKey" localhost
}

function add_localhost_to_ansible() {
	echo
	echo '*** Add localhost to ansible hosts file'
	echo
	ansibleHosts='/etc/ansible/hosts'
	localhostEntry='localhost'
	# http://stackoverflow.com/questions/3557037/appending-a-line-to-a-file-only-if-it-does-not-already-exist
	if ! grep -q -E "^$localhostEntry" "$ansibleHosts" ; then
		# http://stackoverflow.com/questions/82256/how-do-i-use-sudo-to-redirect-output-to-a-location-i-dont-have-permission-to-wr
		echo "$localhostEntry" | sudo tee -a "$ansibleHosts" > /dev/null
	fi
}

function run_ansible_ping() {
	echo
	echo '*** Run ansible ping'
	echo
	ansible all -m ping
}

add_to_sudo
set_git_email
set_git_name
turn_off_automatic_updates
install_epel_repo
install_ansible
check_ansible
create_ssh_keypair
copy_ssh_keypair
add_localhost_to_ansible
run_ansible_ping

