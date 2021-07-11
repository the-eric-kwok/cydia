#!/bin/bash

./build.sh
rm Packages*
dpkg-scanpackages -m . > Packages
bzip2 -k Packages
echo ""
cat Packages
