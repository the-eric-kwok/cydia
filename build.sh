#!/bin/bash

WD="builds"
cd $WD
pkgs=$(find . -type d -maxdepth 1 -mindepth 1 -print)
for pkg in $pkgs; do
    find ${pkg} -name .DS_Store -type f -exec rm {} \;
    version=$(grep "Version:" ${pkg}/DEBIAN/control | sed -e 's/Version: //g')
    name=$(grep "Package:" ${pkg}/DEBIAN/control | sed -e 's/Package: //g')
    arch=$(grep "Architecture:" ${pkg}/DEBIAN/control | sed -e 's/Architecture: //g')
    echo "Building ${name}_${version}_${arch}.deb"
    dpkg -b ${pkg} "${name}_${version}_${arch}.deb"
    mkdir -p ../files/${pkg}
    mv "${name}_${version}_${arch}.deb" "../files/${pkg}"
    echo "`pwd`: copying control file"
    cp ${pkg}/DEBIAN/control ../files/${pkg}
done
cd -
