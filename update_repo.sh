#!/bin/bash

rm Packages*
./dpkg-scanpackages -m . /dev/null >Packages
bzip2 -k Packages
echo ""
cat Packages
