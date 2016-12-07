#!/bin/bash

target="../peterstace.github.io"

hugo &&
    rm -rf $target/* &&
    echo -n "peterstace.io" > $target/CNAME &&
    cp -r public/* $target &&
    pushd $target &&
    git add -A &&
    git commit -m "`date`" &&
    git push &&
    git show &&
    popd
