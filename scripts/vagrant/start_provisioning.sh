#!/usr/bin/env bash

grep -q '. /home/vagrant/app/src/env/activate.sh' /home/vagrant/.bashrc || echo '. /home/vagrant/app/src/env/activate.sh > /dev/null' >> /home/vagrant/.bashrc
