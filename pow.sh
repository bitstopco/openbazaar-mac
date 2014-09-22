#!/bin/bash

set -e

function command_exists {
  #this should be a very portable way of checking if something is on the path
  #usage: "if command_exists foo; then echo it exists; fi"
  type "$1" &> /dev/null
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

function installUbuntu {
  #print commands
  set -x

  sudo apt-get -y update
  for package in python-pip build-essential python-zmq rng-tools python-dev g++ libjpeg-dev zlib1g-dev sqlite3 openssl alien libssl-dev python-virtualenv lintian libjs-jquery git-core
  do
    sudo apt-get -y install $package
  done

  cd ~/
  git clone https://github.com/OpenBazaar/OpenBazaar.git
  cd OpenBazaar 

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