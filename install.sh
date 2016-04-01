#!/bin/bash

VRUBY="2.2.4"
VRAILS="4.2.6"

clear
echo -e "\e[44m------- INICIANDO INSTALACAO RUBY $VRUBY E RAILS $VRAILS -------------\e[0m"

echo -e '\e[45m------- ATUALIZANDO BIBLIOTECAS NECESSARIAS ----------\e[0m'
sudo apt-get -qq update
sudo apt-get install -y git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev

cd $HOME

if [ ! -d "$HOME/.rbenv" ]; then
  echo -e '\e[45m------- INSTALANDO RBENV ----------\e[0m'
  git clone git://github.com/sstephenson/rbenv.git .rbenv
  echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
  echo 'eval "$(rbenv init -)"' >> ~/.bashrc
  #exec $SHELL
  source ~/.bashrc
  echo -e '\e[42m----------- RBENV INSTALADO -------------\e[0m'
else
  echo -e '\e[41m----------- JA POSSUI RBENV -------------\e[0m'
  RBENVV="$(rbenv -v)"
  echo -e "\e[43m----------- ${RBENVV}\e[0m"
fi

if [ ! -d "$HOME/.rbenv/plugins/ruby-build" ]; then
  echo -e '\e[45m------- INSTALANDO RBENV PLUGIN: RUBYBUILD ----------\e[0m'
  git clone git://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
  echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc
  #exec $SHELL
  source ~/.bashrc
  echo -e '\e[42m----------- RBENV PLUGIN: RUBYBUILD INSTALADO -------------\e[0m'
else
  echo -e '\e[41m----------- JA POSSUI RBENV PLUGIN: RUBYBUILD -------------\e[0m'
fi

if [ ! -d "$HOME/.rbenv/plugins/rbenv-gem-rehash" ]; then
  echo -e '\e[45m------- INSTALANDO RBENV PLUGIN: GEM-REHASH -------\e[0m'
  git clone https://github.com/sstephenson/rbenv-gem-rehash.git ~/.rbenv/plugins/rbenv-gem-rehash
  #exec $SHELL
  source ~/.bashrc
  echo -e '\e[42m----------- RBENV PLUGIN: GEM-REHASH INSTALADO -------------\e[0m'
else
  echo -e '\e[41m----------- JA POSSUI RBENV PLUGIN: GEM-REHASH -------------\e[0m'
fi

if [ ! -d "$HOME/.rbenv/plugins/rbenv-vars" ]; then
  echo -e '\e[45m------- INSTALANDO RBENV PLUGIN: VARS -------\e[0m'
  git clone https://github.com/sstephenson/rbenv-vars.git ~/.rbenv/plugins/rbenv-vars
  #exec $SHELL
  source ~/.bashrc
  echo -e '\e[42m----------- RBENV PLUGIN: VARS INSTALADO -------------\e[0m'
else
  echo -e '\e[41m----------- JA POSSUI RBENV PLUGIN: VARS -------------\e[0m'
fi

if ! type ruby > /dev/null 2>&1; then
  echo -e "\e[45m------- INSTALANDO RUBY VERSAO $VRUBY --------\e[0m"
  rbenv install $VRUBY
  rbenv global $VRUBY
  ruby -v
  echo "gem: --no-ri --no-rdoc" > ~/.gemrc
  gem install bundler
  echo -e '\e[42m----------- RUBY INSTALADO -------------\e[0m'
else
  echo -e '\e[41m----------- JA POSSUI RUBY -------------\e[0m'
  RUBYV="$(ruby -v)"
  echo -e "\e[43m----------- ${RUBYV}\e[0m"
fi

if ! type node > /dev/null 2>&1; then
  echo -e '\e[45m-------- INSTALANDO NODE.JS ---------------\e[0m'
  sudo add-apt-repository ppa:chris-lea/node.js -y
  sudo apt-get -qq update
  sudo apt-get install nodejs -y
  echo -e '\e[42m----------- NODE.JS INSTALADO -------------\e[0m'
else
  echo -e '\e[41m----------- JA POSSUI NODE.JS -------------\e[0m'
  NODEV="$(node -v)"
  echo -e "\e[43m----------- ${NODEV}\e[0m"
fi

if ! type rails > /dev/null 2>&1; then
  echo -e "\e[45m----------- INSTALANDO RAILS $VRAILS -------------\e[0m"
  gem install rails -v $VRAILS
  rbenv rehash
  #echo -e '\e[45m----------- TESTANDO RAILS (exibindo versão) -------------\e[0m'
  #rails -v
  echo -e '\e[42m----------- RAILS INSTALADO -------------\e[0m'
else
  echo -e '\e[41m----------- JA POSSUI RAILS -------------\e[0m'
  RAILSV="$(rails -v)"
  echo -e "\e[43m----------- ${RAILSV}\e[0m"
fi

if [ ! -f "/etc/init/puma.conf" ]; then
  echo -e '\e[45m----------- PREPARANDO EXEMPLO DE CONFIGURAÇÃO PUMA -------------\e[0m'
  CPUCORES="$(grep -c processor /proc/cpuinfo)"
  touch ~/puma.rb.sample
  cat <<EOF >> ~/puma.rb.sample
# Change to match your CPU core count
workers ${CPUCORES}

# Min and Max threads per worker
threads 1, 6

app_dir = File.expand_path("../..", __FILE__)
shared_dir = "#{app_dir}/shared"

# Default to production
rails_env = ENV['RAILS_ENV'] || "production"
environment rails_env

# Set up socket location
bind "unix://#{shared_dir}/sockets/puma.sock"

# Logging
stdout_redirect "#{shared_dir}/log/puma.stdout.log", "#{shared_dir}/log/puma.stderr.log", true

# Set master PID and state locations
pidfile "#{shared_dir}/pids/puma.pid"
state_path "#{shared_dir}/pids/puma.state"
activate_control_app

on_worker_boot do
  require "active_record"
  ActiveRecord::Base.connection.disconnect! rescue ActiveRecord::ConnectionNotEstablished
  ActiveRecord::Base.establish_connection(YAML.load_file("#{app_dir}/config/database.yml")[rails_env])
end
EOF
  echo -e '\e[42m----------- ARQUIVO ~/puma.rb.sample PRONTO -------------\e[0m'

  echo -e '\e[45m----------- PREPARANDO ARQUIVOS DE EXECUÇÃO PUMA -------------\e[0m'
  cd ~
  wget https://raw.githubusercontent.com/puma/puma/master/tools/jungle/upstart/puma-manager.conf -O puma-manager.conf.sample
  wget https://raw.githubusercontent.com/puma/puma/master/tools/jungle/upstart/puma.conf -O puma.conf.sample
  echo -e '\e[42m----------- ARQUIVO ~/puma-manager.conf.sample PRONTO -------------\e[0m'

  echo -e '\e[45m----------- MOVENDO ARQUIVOS PUMA PARA /etc/init -------------\e[0m'
  sudo cp ~/puma-manager.conf.sample  /etc/init/puma-manager.conf
  sudo cp ~/puma.conf.sample /etc/init/puma.conf
  sudo touch /etc/puma.conf
  echo -e '\e[42m----------- ARQUIVOS MOVIDOS para /etc/init -------------\e[0m'
  echo -e '\e[42m----------- EDITE O ARQUIVO puma.conf PARA O SEU USUÁRIO DEPLOY (setuid e setuid)-------------\e[0m'
  echo -e '\e[42m----------- INSIRA O CAMINHO DO SEU APLICATOV EM /etc/puma.conf -------------\e[0m'
else
  echo -e '\e[41m----------- JA POSSUI PUMA -------------\e[0m'
fi

if ! type nginx > /dev/null 2>&1; then
  echo -e '\e[45m----------- INSTALANDO NGINX -------------\e[0m'
  sudo apt-get -qq update
  sudo apt-get install nginx -y
  sudo update-rc.d nginx defaults
  echo -e '\e[42m----------- NGINX INSTALADO -------------\e[0m'
  echo -e '\e[45m----------- PREPARANDO MODELO PUMA RAILS APP EM NGINX SITES -------------\e[0m'
  sudo touch /etc/nginx/sites-available/rails.sample
  sudo cat <<EOF >> /etc/nginx/sites-available/rails.sample
upstream app {
    # Path to Puma SOCK file, as defined previously
    server unix:/home/deploy/appname/shared/sockets/puma.sock fail_timeout=0;
}

server {
    listen 80;
    server_name localhost;

    root /home/deploy/appname/public;

    try_files $uri/index.html $uri @app;

    location @app {
        proxy_pass http://app;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_redirect off;
    }

    error_page 500 502 503 504 /500.html;
    client_max_body_size 4G;
    keepalive_timeout 10;
}
EOF
  echo -e '\e[42m----------- ARQUIVO /etc/nginx/sites-available/rails.sample PRONTO -------------\e[0m'
else
  echo -e '\e[41m----------- JA POSSUI NGINX -------------\e[0m'
  NGINXV="$(nginx -v)"
  echo -e "\e[43m----------- ${NGINXV}\e[0m"
fi



echo -e '\e[44m----------- INSTALAÇÃO FINALIZADA -------------\e[0m'
