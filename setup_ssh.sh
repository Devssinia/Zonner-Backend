#!/bin/bash

# Generate SSH Key and Configure SSH
# ssh-keygen -t rsa -b 4096 -f ~/.ssh/selihom_server_rsa -N ""
ssh-keygen -t rsa -b 4096 -C "betekbebe@gmail.com" -f ~/.ssh/github_rsa -N ""
cat <<EOF >~/.ssh/config
    Host github.com
    User git
    Port 22
    Hostname github.com
    IdentityFile ~/.ssh/github_rsa
    TCPKeepAlive yes
    IdentitiesOnly yes
EOF
