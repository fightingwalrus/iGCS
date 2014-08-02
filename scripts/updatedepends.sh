#!/bin/bash

cd "$(git rev-parse --show-toplevel)"

echo "Recursively updating submodules"
git submodule update --init --recursive

echo "Downloading private dependencies"
git archive --format=tar --prefix=dependencies/ \
--remote=git@bitbucket.org:fightingwalrus/fwrfirmwarebins.git master | tar -xf -

git archive --format=tar --prefix=dependencies/ \
--remote=git@bitbucket.org:fightingwalrus/igcsprivateconfig.git master | tar -xf -

