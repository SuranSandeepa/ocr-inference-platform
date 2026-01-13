#!/bin/bash

sudo apt update
sudo apt install -y \
  python3 python3-pip python3-venv \
  curl git build-essential \
  docker.io

# Poetry
curl -sSL https://install.python-poetry.org | python3 -
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
