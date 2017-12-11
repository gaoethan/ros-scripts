#!/bin/bash
export IFS=","

infile="$(realpath $1)"
outfile="$(realpath $2)"
rm $outfile

rm -rf temp
mkdir temp
echo "Entering temp folder.."
cd temp


cat $infile | while read name url; do
    tarname=${url##*/}
    wget $url
    wait

    cmakelists="$(tar -tf $tarname | grep "CMakeLists.txt")"
    wait

    readarray -t  srcdir_array <<<"$cmakelists"
    for each in "${srcdir_array[@]}"
    do
      norepo=${each#*/}
      nocmakelists=${norepo%CMakeLists.txt}
      notrailingslash=${nocmakelists%/}
      echo $notrailingslash
      if [ -z "$notrailingslash" ]
      then
	 echo "$name, $url, $notrailingslash" >> $outfile
      else
	 newname=${notrailingslash##*/}
	 echo "$newname, $url, $notrailingslash" >> $outfile
      fi
    done

    #echo "$name, $url, $srcdir" >> $outfile
    wait
    rm -rf $tarname
done
echo "Exiting temp folder.."
cd ..
echo "Deleting temp folder.."
rm -rf temp/
