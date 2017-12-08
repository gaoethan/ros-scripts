#!/bin/bash
export IFS=","

infile=$1
pwd=$PWD
errfile="lunar-bulk-err.csv"
echo "errfile = $errfile"

echo "0: Reading input file"
cat $infile | while read name url srcdir; do
  echo "0-1: Clearing chroot directory to make space"
  sudo rm -rf /var/lib/mock/*
  wait

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
    sudo echo "$name,$url,$srcdir" >> ../../../ros-scripts/results/$errfile
    echo "UNSUCCESSFUL: $name package creation"
  fi
  wait
  echo "7: Exiting - packages/$name"  
  cd ../../
done
