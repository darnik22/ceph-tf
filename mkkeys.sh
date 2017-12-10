#!/bin/bash

if [ ! -d keys ]; then 
    mkdir keys
fi
if [ ! -f keys/id_rsa ]; then
    ssh-keygen -f keys/id_rsa -N ""
fi

