#!/bin/bash

if [ -d ~/OpenBazaar -a ! -h ~/OpenBazaar ]
then
  # We have an installation so lets update it
  echo "yes"
else
  # We cant find a previous installation.

  cd ~/
  wget https://github.com/OpenBazaar/OpenBazaar/archive/v"$1".zip
  unzip v"$1".zip
  mv OpenBazaar-0.1.0/ OpenBazaar
  rm -rf v"$1".zip

  cd OpenBazaar

  ./configure.sh

fi

