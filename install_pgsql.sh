#!/bin/bash

if ! type psql > /dev/null 2>&1; then

	PGV="9.5"
	PS3='Qual a versão do postgre você deseja instalar? '
	options=("9.3" "9.4" "9.5")
	select opt in "${options[@]}"
	do
	    case $opt in
		"9.3")
		    PGV="9.3"
		    break
		    ;;
		"9.4")
		    PGV="9.4"
		    break
		    ;;
		"9.5")
		    PGV="9.5"
		    break
		    ;;
		*) echo invalid option;;
	    esac
	done

	UBUV=
	PS3='Qual a versão do seu Ubuntu? '
	options=("14.04 - Trusty" "15.10 - Wily" "16.04 - Xenial")
	select opt in "${options[@]}"
	do
	    case $opt in
		"14.04 - Trusty")
		    UBUV="14.04"
		    echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" > /etc/apt/sources.list.d/pgdg.list
		    break
		    ;;
		"15.10 - Wily")
		    UBUV="15.10"
		    echo "deb http://apt.postgresql.org/pub/repos/apt/ wily-pgdg main" > /etc/apt/sources.list.d/pgdg.list
		    break
		    ;;
		"16.04 - Xenial")
		    UBUV="16.04"
		    echo "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main" > /etc/apt/sources.list.d/pgdg.list
		    break
		    ;;
		*) echo invalid option;;
	    esac
	done

	echo -e "\e[44m------- INSTALACAO DO POSTGRESQL $PGV NO UBUNTU $UBUV -------------\e[0m"

	wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
	sudo apt-get -qq update
	echo "$(sudo apt-get -qq install -y postgresql-$PGV)"

	echo -e "\e[42m----------- POSTGRESQL $PGV INSTALADO INSTALADO -------------\e[0m"

else
	echo -e '\e[41m----------- JA POSSUI POSTREGRESQL -------------\e[0m'
	PSQLV="$(psql --version)"
	echo -e "\e[43m----------- ${PSQLV}\e[0m"
fi
