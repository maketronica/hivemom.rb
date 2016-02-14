#!/usr/bin/env bash
parent_path=$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )
cd "$parent_path"

sudo apt-get install sqlite3 libsqlite3-dev ruby-dev
sudo gem install bundler --no-rdoc --no-ri
bundle install
rake db:migrate

sudo cp ../scripts/init.rb /etc/init.d/hivemom
sudo chmod 755 /etc/init.d/hivemom
sudo update-rc.d hivemom defaults
sudo service hivemom restart
