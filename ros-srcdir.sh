#!/bin/bash
export IFS=","

rm -rf temp
mkdir temp
echo "Entering temp folder.."
cd temp

infile="../results/lunar-url.csv"
outfile="../results/lunar-srcdir.csv"

cat $infile | while read name url; do
    tarname=${url##*/}
    wget $url
    wait
    srcdir="$(tar -tf $tarname | grep "CMakeLists.txt")"
    wait
    echo "$name, $url, $srcdir" >> $outfile
    wait
    rm -rf $tarname
done
echo "Exiting temp folder.."
cd ..

