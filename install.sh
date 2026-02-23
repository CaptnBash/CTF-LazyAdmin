#!/bin/bash
set -euo pipefail # fail on error code, unset variables and pipeline fails on error code
umask 0077

# make sure the current working directory is set to the root folder of the repo
SCRIPT_DIR=$(dirname "$0")
cd "$SCRIPT_DIR" || exit 1

echo "Updating and upgrading system packages..."
apt update

curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
apt install -y nodejs
clear

######## SYSTEM SETTINGS ########
# netplan
cp network-settings.yaml /etc/netplan/99-override.yaml

# issue
cp issue /etc/issue

hostnamectl set-hostname --static CTF-LazyDev
hostnamectl set-hostname --pretty CTF-LazyDev

# MOTD
chmod a-x /etc/update-motd.d/10-help-text 2>/dev/null || true
chmod a-x /etc/update-motd.d/90-updates-available 2>/dev/null || true
chmod a-x /etc/update-motd.d/91-contract-ua-esm-status 2>/dev/null || true
chmod a-x /etc/update-motd.d/91-release-upgrade 2>/dev/null || true

######## USERS ########

usermod -s /bin/bash www-data
echo "www-data:my_password_is_super_secure_because_it_is_so_long" | chpasswd

useradd -m -s /bin/bash dev
echo "dev:dev123" | chpasswd
echo 'flag{Th1s_d0es_n0t_l00k_g00d!}' > /home/dev/flag.txt
chown dev:dev /home/dev/flag.txt
install -o dev -g dev -m 750 source.zip /home/dev/source.zip


######## Node Server ########
mkdir -p /var/www/html 
cp node_server/* /var/www/html/
echo 'flag{BASE64_1S_N0T_ENCRYPT10N}' > /var/www/flag.txt
cd /var/www/html
npm install
cd -

chown -R www-data:www-data /var/www/*
chmod 755 /var/www/
cp node_dev_portal.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable --now node_dev_portal || echo "Warning: Service did not start correctly."


######## PRIVESC ########
install -o root -g www-data -m 770 -d /var/scripts
install -m 744 backup.sh /opt/backup.sh

(crontab -l 2>/dev/null || true; echo "*/2 * * * * /opt/backup.sh") | crontab -
echo 'flag{TH3_CR0N_JOB_W1NS}' > /root/flag.txt
chmod 644 /root/flag.txt

######## Cleanup ########

rm -r ~/.ssh
rm -rf "$PWD"

DEFAULT_USER=$(id -nu 1000 2>/dev/null)
echo "Removing user: $DEFAULT_USER"

userdel -r -f "$DEFAULT_USER"
delgroup "$DEFAULT_USER"

# clean bash history
rm ~/.bash_history 2>/dev/null || true
history -c
