#!/bin/sh
set -e

#install ruby
apt update
apt install -y ruby-full ruby-bundler build-essential
