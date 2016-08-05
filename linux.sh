#!/bin/bash

# Get Ubuntu release name (the animal thingie)
RELEASE="$(lsb_release -cs)"

# Store current user name (sudo sometimes clobbers this)
CURRENT_USER=$USER

# Location of our nice .bashrc
BASHRC_LOCATION="https://raw.githubusercontent.com/lighthouse-labs/setup-scripts/master/deps/bashrc.sh"

# Ruby version to use
RUBY_VERSION="2.3.1"

cat <<EOF

LighthouseLabs Linux Setup
--------------------------

Welcome to LighthouseLabs! This script will help you prepare your machine for
the web bootcamp, as well as the prep course. The process should be mostly
automatic. You'll be given instructions on how to proceed when you need to
intervene, so READ THE INSTRUCTIONS CAREFULLY!

You'll be asked for your password below. This is necessary to install some of
the programs that will be used during the course.

EOF

# Trigger sudo permissions - this should persist through the script
if [ "$(sudo whoami)" != "root" ]; then
cat <<EOF

It looks like you typed the wrong password too many times!
Please run this script again.

EOF
  exit 1
fi


printf "\n\n\n--- Updating software package information\n\n"
# Add MongoDB repo
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
echo "deb http://repo.mongodb.org/apt/ubuntu $RELEASE/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list
# Update!
sudo apt-get -y update


printf "\n\n\n--- Installing essential dev tools and databases\n\n"
sudo apt-get -y install build-essential git tig vim wget htop tmux screen libreadline-dev \
                mongodb-org postgresql postgresql-contrib postgresql-client postgresql-server-dev-all \
                redis-server redis-tools



printf "\n\n\n--- Configuring MongoDB\n\n"
# Blame bash for this horrible HEREDOCS syntax
if [ "$RELEASE" == "xenial" ]; then
(
cat <<-'EOF'
[Unit]
Description=High-performance, schema-free document-oriented database
After=network.target
Documentation=https://docs.mongodb.org/manual

[Service]
User=mongodb
Group=mongodb
ExecStart=/usr/bin/mongod --quiet --config /etc/mongod.conf

[Install]
WantedBy=multi-user.target
EOF
)> /tmp/mongodb.service
  sudo mv /tmp/mongodb.service /lib/systemd/system/mongodb.service
  sudo systemctl enable mongodb
fi


printf "\n\n\n--- Configuring Postgres\n\n"
sudo -u postgres createuser --superuser $CURRENT_USER
sudo -u postgres createdb $CURRENT_USER


printf "\n\n\n--- Installing Node.js with nvm\n\n"
export NVM_DIR="$HOME/.nvm" && (
  git clone https://github.com/creationix/nvm.git "$NVM_DIR"
  cd "$NVM_DIR"
  git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" origin`
) && . "$NVM_DIR/nvm.sh"
nvm install node
nvm use node


printf "\n\n\n--- Installing Ruby with rbenv and ruby-build\n\n"
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
cd ~/.rbenv && src/configure && make -C src
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
rbenv install $RUBY_VERSION && rbenv global $RUBY_VERSION
gem install --no-ri --no-rdoc bundler pry


printf "\n\n\n--- Terminal configuration\n\n"
mkdir -p ~/bin
if [ -f ~/.bashrc ]; then
  mv ~/.bashrc ~/bashrc.backup
fi
wget $BASHRC_LOCATION -O ~/.bashrc


printf "\n\n\n--- DONE! ---\n\n"
cat <<EOF

Your computer is now ready for the web bootcamp!
Press enter to reload the terminal and start building awesome things.

EOF
read
cd ~
clear
exec bash
