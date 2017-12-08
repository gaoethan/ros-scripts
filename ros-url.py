import yaml
import os

infile = "rosdistro/lunar/distribution.yaml"
outdir = "results"
if not os.path.exists(outdir):
   os.makedirs(outdir)
outfile = outdir + "/lunar-url.csv"
errfile = outdir + "/lunar-no-url.csv"

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
               version = release.get('version')
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
