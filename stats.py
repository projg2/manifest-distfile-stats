#!/usr/bin/env python3

import collections
import hashlib
import math
import sys


class Group(object):
    count = 0
    size = 0


def makedict(it):
    it = iter(it)
    while True:
        try:
            i = next(it)
        except StopIteration:
            return
        j = next(it)
        yield (i, j)


class File(object):
    def __init__(self, l):
        ftype, self.filename, size, *hashes = l.split()
        assert ftype == 'DIST'
        self.size = int(size)
        self.hashes = dict(makedict(hashes))


class keys(object):
    @staticmethod
    def filename(f):
        return f.filename[0]

    @staticmethod
    def sha512sum(f):
        return f.hashes['SHA512'][0:1]

    @staticmethod
    def filename_checksum(f):
        h = hashlib.sha512()
        h.update(f.filename.encode('utf8'))
        return h.hexdigest()[0:1]

    @staticmethod
    def sha512sum2(f):
        return f.hashes['SHA512'][0:2]

    @staticmethod
    def filename_checksum2(f):
        h = hashlib.sha512()
        h.update(f.filename.encode('utf8'))
        return h.hexdigest()[0:2]


groups = collections.defaultdict(Group)
group_func = getattr(keys, sys.argv[1])

for l in sys.stdin:
    f = File(l)
    g = group_func(f)
    groups[g].count += 1
    groups[g].size += f.size

for k, g in sorted(groups.items()):
    print('"%s"\t%d' % (k, g.count))
