#!/bin/bash

cd "$(git rev-parse --show-toplevel)"

git submodule update --init --recursive

git archive --format=tar --prefix=dependencies/ \
--remote=git@bitbucket.org:fightingwalrus/fwrfirmwarebins.git master | tar -xf -
