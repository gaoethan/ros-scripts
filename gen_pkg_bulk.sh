#!/bin/bash
sname=$(basename -- "$0")
export IFS=","

infile="$(realpath $1)"
outfile="$(realpath ros-scripts/results/ros-pkg-bulk.csv)"
errfile="$(realpath ros-scripts/results/ros-pkg-bulk-err.csv)"
errlog="$(realpath ros-scripts/results/ros-pkg-bulk-errlog.csv)"

rm $outfile
rm $errfile
rm $errlog

echo "$sname: Reading input file"
cat $infile | while read name url srcdir; do
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

  echo "$sname: Clearing chroot directory to make space"
  sudo rm -rf /var/lib/mock/*
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
     #step1=$($autospecnew)
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

     #echo "$sname: Cleaning package folder"
     #make clean && make proper
     #wait

     echo "$sname: Exiting - packages/$name"
     cd ../../

     echo "$name,$url,$srcdir," >> $outfile
     echo "SUCCESSFUL: $name package creation"
  else
     echo "$name,$url,$srcdir," >> $errfile
     rootlog=$(grep "Error" packages/$name/results/root.log)
     buildlog=$(grep -m 1 -A 3 "Error" packages/$name/results/build.log)
     echo "$name ; $url ; $srcdir ; $rootlog ; $buildlog" >> $errlog
  fi
  wait

 # echo "$sname: Cleaning mock"
 # make mockclean && make mockproper
 # wait

done
echo "$sname finished at $(date)"  >> ros-scripts/results/done.txt
