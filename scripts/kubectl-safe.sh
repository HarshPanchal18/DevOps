#!/bin/bash

# chmod +x scripts/kubectlsafe.sh
# ln -s $(pwd)/scripts/kubectlsafe.sh /usr/local/bin/kubectl-safe
# echo "alias kubectl='kubectl-safe'" >> $HOME/.bashrc

kubectlbin="/usr/bin/kubectl"

if [ -z $1 ] || [ "x$1" == "x" ]; then
    exit 0
fi

if [ $1 == "apply" ] || [ $1 == "create" ] || [ $1 == "delete" ] || [ $1 == "edit" ] || [ $1 == "patch" ] || [ $1 == "replace" ] || [ $1 == "scale" ]; then
    cc=$($kubectlbin config current-context);
    read -p $'Current context is \e[1m'$cc$'\e[0m.Do you want to continue? [y/N] ' -n1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        $kubectlbin $@
        exit 0
    fi
else
    $kubectlbin $@
fi