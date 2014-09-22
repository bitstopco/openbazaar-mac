#!/bin/bash

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
  for package in python-pip build-essential python-zmq rng-tools python-dev g++ libjpeg-dev zlib1g-dev sqlite3 openssl alien libssl-dev python-virtualenv lintian libjs-jquery
  do
    sudo apt-get -y install $package
  done

  if [ ! -d "./env" ]; then
    virtualenv env
  fi

  ./env/bin/pip install ./pysqlcipher
  ./env/bin/pip install -r requirements.txt

  doneMessage
}

if [[ $OSTYPE == darwin* ]] ; then
  installMac
elif [[ $OSTYPE == linux-gnu || $OSTYPE == linux-gnueabihf ]]; then
  UNAME=$(uname -a)
  if [ -f /etc/arch-release ]; then
      if [[ "$UNAME" =~ alarmpi ]]; then
          echo "$UNAME"
          echo Found Raspberry Pi Arch Linux
          
      else
          echo Arch
      fi
  elif [ -f /etc/gentoo-release ]; then
    echo Portage
  elif [ -f /etc/fedora-release ]; then
    echo Fedora
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
      installUbuntu
    fi

  fi
fi