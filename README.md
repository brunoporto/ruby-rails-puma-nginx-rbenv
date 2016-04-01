## Instalação

Execute o arquivo **install.sh** e aguarde a instalação finalizar.
```sh
cd ~
sudo chmod +x install.sh
./install.sh
```
## Configuração

### PUMA

Configure o arquivo `/etc/init/puma.conf`
```sh
sudo /etc/init/puma.rb
```

Altere os usuários de execução do PUMA para o seu usuário de deploy:
```
setuid seu_usuario_deploy
setgid seu_usuario_deploy
```

Abra o arquivo `/etc/puma.conf` e insira o endereço do seu aplicativo:
```
/home/meu_usuario_deploy/meu_app
```

Para iniciar todos os apps gerenciados pelo puma use: 
```sh
sudo start puma-manager
```

Para iniciar um app em particular use:
```sh
sudo start puma app=/home/meu_usuario_deploy/meu_app
```

Para parar ou reiniciar o PUMA
```sh
sudo stop puma-manager
sudo restart puma-manager
```

**Lembrete:** O PUMA irá procurar um socket em `shared/sockets/puma.sock`. Mas somente após a configuração do proxy reverso do nginx, veja o arquivo rails.sample

### NGINX

Foi gerado um exemplo de configuração de aplicativo em `/etc/nginx/sites-available/rails.sample`. Acesse e faça as modificações necessárias, dentre elas está em configurar corretamente o caminho para o seu aplicativo. Troque o endereço abaixo para o caminho completo do seu aplicativo Rails.
```
/home/deploy/appname/public
```



