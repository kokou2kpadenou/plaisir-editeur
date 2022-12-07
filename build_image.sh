#!/bin/bash
# Color
RED='\033[0;31m'
NC='\033[0m'  # No Color#

echo "Creation of dnvim (neovim container) image"
echo "------------------------------------------"
echo

password=""
password2="2"

while [[ "$password" = "" || "$password" != "$password2" ]]; do
  read -s -p "Enter root password: " password
  echo
  read -s -p "Confirm root password: " password2
  echo
  [[ "$password" = "" ]] && echo -e "${RED}User password cannot be empty${NC}" || \
  [[ "$password" == "$password2" ]] || echo -e "${RED}Passwords did not match${NC}"
done


# buid the image
docker build --build-arg user=$USER --build-arg password="${password}" --build-arg uid=$(id -u) --build-arg gid=$(id -g) -t saint .
