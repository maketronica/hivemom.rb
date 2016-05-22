#!/usr/bin/env bash
parent_path=$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )
cd "$parent_path"

sudo apt-get install sqlite3 libsqlite3-dev ruby-dev
sudo gem install bundler --no-rdoc --no-ri
bundle install
rake db:migrate

sudo cp ../config/hivemom.logrotate /etc/logrotate.d/hivemom
sudo chmod 644 /etc/logrotate.d/hivemom

sudo cp ../scripts/server_init.rb /etc/init.d/hivemom
sudo chmod 755 /etc/init.d/hivemom
sudo update-rc.d hivemom defaults
sudo service hivemom restart

sudo cp ../scripts/compositor_init.rb /etc/init.d/hivemom_compositor
sudo chmod 755 /etc/init.d/hivemom_compositor
sudo update-rc.d hivemom_compositor defaults
sudo service hivemom_compositor restart
