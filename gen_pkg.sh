#!/bin/bash
sname=$(basename -- "$0")

name=$1
url=$2
srcdir=$3
echo "$sname: $name, $url, $srcdir"

echo "$sname: Removing - packages/$name"
rm -rf packages/$name
wait

echo "$sname: Creating - packages/$name"
mkdir packages/$name
wait

if [ -n "$srcdir" ]; then
   echo "$sname: Writing - packages/$name/cmake_srcdir"
   echo "../$srcdir/" > packages/$name/cmake_srcdir
fi
wait

autospecnew="make autospecnew URL=$url NAME=$name"
echo "$sname: $autospecnew"
#step1=$($autospecnew)
step1=$(make autospecnew URL=$url NAME=$name)
wait

if [[ $step1 == *"Cannot find any license"* ]]; then
  echo "$sname: Creating license file"
  echo BSD-3-Clause > packages/$name/$name.license
  wait
  echo "$sname: Trying again: $autospecnew"
  #step2=$($autospecnew)
  step1=$(make autospecnew URL=$url NAME=$name)
  wait
fi

if [[ $step1 == *"RPM build successful"* ]]; then
   echo "$sname: Entering - packages/$name"
   cd packages/$name
   wait

   echo "$sname: Adding to repo"
   make repoadd
   wait

   make clean && make proper
   wait

   make mockclean && make mockproper
   wait

   echo "SUCCESSFUL: $name package creation"
   wait   
else
   echo "UNSUCCESSFUL: $name package creation"
fi
