import yaml
import os
import sys
import urllib.request
import subprocess
import shlex

if len(sys.argv) == 1:
   distro = "lunar" # default distro
else:
   distro = sys.argv[1]

ros1 = ["groovy", "hydro", "indigo", "jade", "kinetic", "lunar", "melodic"]

if distro in ros1:
   disturl = "https://raw.githubusercontent.com/ros/rosdistro/master/" + distro + "/distribution.yaml"
else:
   disturl = "https://raw.githubusercontent.com/ros2/rosdistro/ros2/" + distro + "/distribution.yaml"

outdir = "results/"
if not os.path.exists(outdir):
   os.makedirs(outdir)

infile = outdir + distro + ".yaml"
outfile = outdir + distro + "-srcurl.csv"
errfile = outdir + distro + "-srcurl-err.csv"

urllib.request.urlretrieve (disturl, infile)

o = open(outfile, 'w')
e = open(errfile, 'w')
with open(infile, 'r') as stream:
    try:
        input = yaml.load(stream)
        repositories = input['repositories'].items()
        for repo in repositories:
            name = repo[0]
            source = repo[1].get('source')
            release = repo[1].get('release')
            if source and release:
               url = source.get('url')
               if distro in ros1:
                  version = release.get('version')
               else:
                  version = source.get('version')
               if url and version:
                  url1 = url.replace('.git','')
                  version1 = version.replace('-0','')
                  path = url1 + '/' + 'archive' + '/' + version1 + '.tar.gz'
                  output = name + ',' + path + '\n'
                  o.write(output)
               else:
                  e.write(name + '\n')
            else:
               e.write(name + '\n')
    except yaml.YAMLError as exc:
        print(exc)

infile = outfile
outfile = outdir + distro + "-srcdir.csv"
subprocess.call(shlex.split('./get_srcdir.sh ' + infile + ' ' + outfile))
