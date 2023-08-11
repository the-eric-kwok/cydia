#!/bin/bash

set -e

WD="Packages.d"
if [ ! -d $WD ]; then
    echo "请将构建后的 deb 包放到 Packages.d 目录下，然后重新运行此脚本"
    mkdir $WD
    exit 1
fi

# 规范化命名
cd $WD
pkgs=$(find . -type f -name "*.deb" -maxdepth 1 -mindepth 1 -print)
for pkg in $pkgs; do
    dpkg -e $pkg /tmp/cydia
    version=$(grep "Version:" /tmp/cydia/control | sed -e 's/Version: //g')
    name=$(grep "Package:" /tmp/cydia/control | sed -e 's/Package: //g')
    arch=$(grep "Architecture:" /tmp/cydia/control | sed -e 's/Architecture: //g')
    mkdir -p $name
    mv "$pkg" "${name}/${name}_${version}.deb"
    rm -rf /tmp/cydia
done
cd -

# 生成 Packages 文件
rm -f Packages Packages.bz2
dpkg-scanpackages -m Packages.d > Packages
bzip2 -k Packages
echo "Done!"

