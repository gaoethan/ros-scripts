#!/bin/bash
echo "0: Clearing chroot directory to make space"
sudo rm -rf /var/lib/mock/*
wait

name=$1
url=$2
srcdir=$3
echo "$name, $url, $srcdir"

echo "1: make autospecnew URL=$url NAME=$name"
step1=$(make autospecnew URL=$url NAME=$name)
wait

if [[ $step1 == *"Cannot find any license"* ]]; then
  echo "2: Creating license file"
  echo BSD-3-Clause > packages/$name/$name.license
fi

if [ -n "$srcdir" ]; then
   echo "3: Writing - packages/$name/cmake_srcdir"
   echo "../$srcdir/" > packages/$name/cmake_srcdir
fi
wait

echo "4: Entering - packages/$name"
cd packages/$name
wait

echo "5: make autospecnogit"
step2=$(make autospecnogit)
wait

if [[ $step2 == *"RPM build successful"* ]]; then
   echo "6: Adding to repo"
   make repoadd
   echo "SUCCESSFUL: $name package creation"
else
   echo $step2
   echo "UNSUCCESSFUL: $name package creation"
fi
