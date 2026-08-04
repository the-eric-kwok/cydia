#!/bin/bash

set -euo pipefail

cd "$(dirname "$0")"

packages_dir="Packages.d"
if [ ! -d "$packages_dir" ]; then
    echo "请将构建后的 deb 包放到 Packages.d 目录下，然后重新运行此脚本"
    mkdir -p "$packages_dir"
    exit 1
fi

while IFS= read -r -d '' package; do
    package_id="$(dpkg-deb -f "$package" Package)"
    version="$(dpkg-deb -f "$package" Version)"
    destination="$packages_dir/$package_id/${package_id}_${version}.deb"
    mkdir -p "$(dirname "$destination")"
    mv "$package" "$destination"
done < <(find "$packages_dir" -maxdepth 1 -type f -name '*.deb' -print0)

dpkg-scanpackages -m "$packages_dir" /dev/null > Packages.new
gzip -9 -c Packages.new > Packages.gz.new
bzip2 -9 -c Packages.new > Packages.bz2.new
xz -9 -c Packages.new > Packages.xz.new

mv Packages.new Packages
mv Packages.gz.new Packages.gz
mv Packages.bz2.new Packages.bz2
mv Packages.xz.new Packages.xz

file_digest() {
    case "$1" in
        MD5Sum) md5 -q "$2" ;;
        SHA1) shasum -a 1 "$2" | awk '{print $1}' ;;
        SHA256) shasum -a 256 "$2" | awk '{print $1}' ;;
    esac
}

{
    echo "Origin: Eric's Repo"
    echo "Label: Eric's Repo"
    echo "Suite: stable"
    echo "Version: 1.0"
    echo "Codename: ios"
    echo "Architectures: iphoneos-arm iphoneos-arm64 all"
    echo "Components: main"
    echo "Description: Eric's iOS jailbreak package repository."
    echo "Date: $(LC_ALL=C date -u '+%a, %d %b %Y %H:%M:%S +0000')"

    for algorithm in MD5Sum SHA1 SHA256; do
        echo "$algorithm:"
        for index in Packages Packages.gz Packages.bz2 Packages.xz; do
            digest="$(file_digest "$algorithm" "$index")"
            size="$(wc -c < "$index" | tr -d ' ')"
            printf ' %s %16s %s\n' "$digest" "$size" "$index"
        done
    done
} > Release.new

mv Release.new Release
echo "Repository metadata updated."
