#!/bin/bash

target="../peterstace.github.io"

docker-compose -f docker-compose-build.yml up &&
    sudo chown -R $(id -u):$(id -g) blog/public &&
    rm -rf $target/* &&
    echo -n "peterstace.io" > $target/CNAME &&
    cp -r blog/public/* $target &&
    pushd $target &&
    git add -A &&
    git commit -m "`date`" &&
    git push &&
    git show &&
    popd
