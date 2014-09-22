#!/bin/bash

set -e

function command_exists {
  #this should be a very portable way of checking if something is on the path
  #usage: "if command_exists foo; then echo it exists; fi"
  type "$1" &> /dev/null
}

function openbazaarSource {
  cd ~/
  git clone https://github.com/OpenBazaar/OpenBazaar.git
  cd OpenBazaar 
}

function doneMessage {
  echo ""
  echo "OpenBazaar configuration finished."
  echo "type './run.sh; tail -f logs/production.log' to start your OpenBazaar servent instance and monitor logging output."
  echo ""
  echo ""
  echo ""
  echo ""
}

function installMac {
  #print commands (useful for debugging)
  #set -x  #disabled because the echos and stdout are verbose enough to see progress

  #install brew if it is not installed, otherwise upgrade it
  if ! command_exists brew ; then
    echo "installing brew..."
    ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
  else
    echo "updating, upgrading, checking brew..."
    brew update
    brewDoctor
    brewUpgrade 
    brew prune
  fi
  
  #install gpg/sqlite3/python/wget if they aren't installed
  for dep in gpg sqlite3 python wget git
  do
    if ! command_exists $dep ; then
      brew install $dep
    fi
  done

  #more brew prerequisites
  brew install openssl zmq

  openbazaarSource

  #python prerequisites
  #python may be owned by root, or it may be owned by the user
  PYTHON_OWNER=$(stat -n -f %u `which python`)
  if [ "$PYTHON_OWNER" == "0" ]; then
    #root owns python
    EASY_INSTALL="sudo easy_install"
    PIP="sudo pip"
  else
    EASY_INSTALL="easy_install"
    PIP="pip"
  fi

  #install pip if it is not installed
  if ! command_exists pip ; then
    $EASY_INSTALL pip
  fi

  #install python's virtualenv if it is not installed
  if ! command_exists virtualenv ; then
    $PIP install virtualenv
  fi

  #create a virtualenv for OpenBazaar
  if [ ! -d "./env" ]; then
    virtualenv env
  fi

  # set compile flags for brew's openssl instead of using brew link --force
  export CFLAGS="-I$(brew --prefix openssl)/include"
  export LDFLAGS="-L$(brew --prefix openssl)/lib"

  #install python deps inside our virtualenv
  ./env/bin/pip install -r requirements.txt
  ./env/bin/pip install ./pysqlcipher

  doneMessage
}

function installUbuntu {
  #print commands
  set -x

  sudo apt-get -y update
  for package in git-core python-pip build-essential python-zmq rng-tools python-dev g++ libjpeg-dev zlib1g-dev sqlite3 openssl alien libssl-dev python-virtualenv lintian libjs-jquery
  do
    sudo apt-get -y install $package
  done

  openbazaarSource

  if [ ! -d "./env" ]; then
    virtualenv env
  fi

  ./env/bin/pip install ./pysqlcipher
  ./env/bin/pip install -r requirements.txt

  doneMessage
}

if [[ $OSTYPE == darwin* ]] ; then
  echo "$UNAME"
  echo "mac"
elif [[ $OSTYPE == linux-gnu || $OSTYPE == linux-gnueabihf ]]; then
  UNAME=$(uname -a)
  if [ -f /etc/arch-release ]; then
      if [[ "$UNAME" =~ alarmpi ]]; then
          echo "$UNAME"
          echo Found Raspberry Pi Arch Linux
          
      else
          echo "$UNAME"
          echo Arch
      fi
  elif [ -f /etc/gentoo-release ]; then
    echo Portage
  elif [ -f "/etc/redhat-release" ]; then
    
    rhos="Fedora CentOS Red Hat"
    for i in $rhos; do
        
      if [ ! -z "`/bin/grep $i /etc/redhat-release`" ]; then
            
        if [[ $i = "CentOS" ]]; then
          echo "$UNAME"
          echo "CentOS"

        elif [[ $i = "Fedora" ]]; then
          echo "$UNAME"
          echo "Fedora"

        elif [[ $i = "Red Hat" ]]; then
          echo "$UNAME"
          echo "Red Hat"

        fi

      fi
    done

  elif grep Raspbian /etc/os-release ; then
    echo Found Raspberry Pi Raspbian
  else
    echo Ubuntu

    if [ -d ~/OpenBazaar -a ! -h ~/OpenBazaar ]
    then
      # We have an installation so lets update it
      echo "yes"
    else
      # We cant find a previous installation.
      echo "Installing on Ubuntu"
      installUbuntu
    fi

  fi
fi