#!/bin/bash

cd /var/www/repo
rm Packages*
./dpkg-scanpackages -m . /dev/null >Packages
bzip2 -k Packages
cd -
echo ""
cat Packages
