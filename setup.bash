#!/usr/bin/env bash
sudo apt-get install sqlite3 libsqlite3-dev ruby-dev
sudo gem install bundler --no-rdoc --no-ri
bundle install #--without development test
rake db:migrate
