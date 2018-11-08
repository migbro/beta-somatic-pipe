#!/usr/bin/env python

import sys
if len(sys.argv) < 2 or sys.argv[1] == '-h' or sys.argv[1] == '--help':
    sys.stderr.write('Quick and dirty vcf sample rename.  Pipe STDIN vcf and name of sample to use as arg\n'
                     'Usage: ' + sys.argv[0] + ' <normal_sample_name> <tumor_sample_name>\n')
    exit(1)
normal = sys.argv[1]
tumor = sys.argv[2]

f = 0
for line in sys.stdin:
    if line[0:6] == '#CHROM' and f == 0:
        old = line.rstrip('\n').split('\t')
        sys.stderr.write('Replacing ' + old[9] + ' with ' + normal 
        + ' and ' + old[10] + ' with ' + tumor + '\n')
        old[9] = normal
        old[10] = tumor
        sys.stdout.write('\t'.join(old) + '\n')
        f = 1
    elif f == 0:
        sys.stdout.write(line)
    else:
        sys.stdout.write(line)
        break
for line in sys.stdin:
    sys.stdout.write(line)
