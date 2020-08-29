#!/usr/bin/env bash


function main {

case $1 in
    "k8s-master")
        ansible-playbook -i 10.1.1.10, -u admin -vvv "${@:2}" k8s-master.yml
    ;;

    *)
        echo "Invalid Command $1"
    ;;
esac
}


main "$@"