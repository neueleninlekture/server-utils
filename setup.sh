### personal server quick setup script
# yes i will edit system files from a script run as root
# no you cannot stop me

## choose hostname
printf "System hostname: "
read -r custom_hostname
echo "$custom_hostname" > /etc/hostname

## update system and install basic packages
echo "UPDATING PACKAGES..."
apt update && apt upgrade
apt install neovim git curl rsync nginx python3-certbot-nginx ufw make sudo

## finicky networking stuff
echo "SETTING UP NETWORKING..."
sed 10q -i /etc/network/interfaces 
echo "auto eth0" >> /etc/network/interfaces

# ipv6 configuration (open buyvm stallion for this info)
echo "iface eth0 inet6 static" >> /etc/network/interfaces
printf "IPV6 Address: "
read -r ipv6_addr
echo "	address $ipv6_addr" >> /etc/network/interfaces
printf "IPV6 Netmask: "
read -r ipv6_netm
echo "	netmask $ipv6_netm" >> /etc/network/interfaces
printf "IPV6 Gateway: "
read -r ipv6_gate
echo "	gateway $ipv6_gate" >> /etc/network/interfaces

# same as above but for ipv4
echo "\
" >> /etc/network/interfaces
echo "iface eth0 inet static" >> /etc/network/interfaces
printf "IPV4 Address: "
read -r ipv4_addr
echo "	address $ipv4_addr" >> /etc/network/interfaces
printf "IPV4 Netmask: "
read -r ipv4_netm
echo "	netmask $ipv4_netm" >> /etc/network/interfaces
printf "IPV4 Gateway: "
read -r ipv4_gate
echo "	gateway $ipv4_gate" >> /etc/network/interfaces

## disabing ssh password login
echo "DISABLING SSH PASSWORD LOGIN..."
sed -i 's/UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config 
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config 

## ufw. allow ssh and mail
echo "SETTING UP FIREWALL..."
ufw default deny incoming
ufw allow in ssh
ufw allow 'WWW Full'
ufw allow in IMAPS
ufw allow in POP3
ufw allow in SMTP
ufw allow in 'Mail Submission'

## bashrc
echo "SETTING UP BASH..."
echo "# abe's bashrc
shopt -s autocd

alias grep='grep --color=auto'
alias ls='ls -NF --color=auto --group-directories-first'

alias ss='systemctl'
alias jxe='journalctl -xe'

alias gs='git status'
alias ga='git add .'
alias gcm='git commit -m'
alias gcl='git clone'
alias gpu='git push origin master'
alias gfu='git pull origin master'

alias mkd='mkdir -p'
alias rmd='rm -rfd'
mkcd () {
  test -d "$1" || mkdir -p "$1" && cd "$1"
}

alias vi='nvim'
alias wget='wget -c'
" > ~/.bashrc
source ~/.bashrc

# ## nginx
# echo "SETTING UP NGINX..."

# printf "Main site name (e.g.: abe): "
# read -r new_site_name

# printf "Main site domain (e.g.: abe.net.br): "
# read -r new_site_domain

# sed -i '/^#/d' /etc/nginx/sites-available/default
# sed -i 's/default_server//g' /etc/nginx/sites-available/default
# cp /etc/nginx/sites-available/default /etc/nginx/sites-available/$new_site_name
# sed -i 's/\/var\/www\/html/\/var\/www\/$new_site_name/g' /etc/nginx/sites-available/$new_site_name 
# sed -i 's/_;/$main_site_domain;/g' /etc/nginx/sites-available/$new_site_name 
# cp /etc/nginx/sites-available/default /etc/nginx/sites-available/mail
# sed -i 's/\/var\/www\/html/\/var\/www\/mail/g' /etc/nginx/sites-available/mail 
# sed -i 's/_;/mail.$new_site_domain;/g' /etc/nginx/sites-available/mail 

# ln -s /etc/nginx/sites-available/$new_site_name /etc/nginx/sites-enabled/
# ln -s /etc/nginx/sites-available/mail /etc/nginx/sites-enabled/

# systemctl reload nginx

# ## certbot
# echo "SETTING UP CERTBOT..."
# certbot --nginx

# ## set up the site
# echo "DOWNLOADING WEBSITE DATA..."
# git clone https://github.com/neueleninlekture/mirror-tools.git /var/www/$new_site_name
# cd /var/www/$new_site_name/
# ./mirror.sh
# cd 

# ## clone the mailscript
# echo "CLONING MAIL SCRIPT..."
# wget lukesmith.xyz/emailwiz.sh
# chmod +x emailwiz.sh
# ./emailwiz.sh

# ## adding mail user accounts
# echo "CREATING MAIL USER ACCOUNTS..."
# printf "New mail user name: "
# read -r new_user
# useradd -G mail -m $new_user
# passwd $new_user
