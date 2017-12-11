===========
ros-scripts
===========
Set of helper scripts to automate bulk creation of ROS rpm specs and packages for Clear Linux.

License
=======
TBD

Input
=====
1) get_srcdir.py
   Fetches the srcurl and srcdir of all the package repositories for a given ROS distro.
   
   'python get_srcdir.py <rosdistro>'
   
   E.g. 'python get_srcdir.py melodic' or 'python get_srcdir.py bouncy'
   The output consists of a <srcurl csv file>, <srcdir csv file> and an <err csv file> in the "results/" folder.

   
2) gen_pkg.sh
   Generates the spec file and rpms and adds them to the local repo for the given input package.
   Currently ROS2 is not supported.
   
   './gen_pkg.sh <name> <url> <srcdir>'
   
3) gen_pkg_bulk.sh
   Generates the spec files and rpms and adds them to the local repo for all the packages listed in the input file.
   
   './gen_pkg_bulk.sh <input csv file>'

   An <output csv file> and an <err csv file> is generated in the "results/" folder.

