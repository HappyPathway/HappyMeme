#!/usr/bin/env python2.7
from boto import ec2
import sys

def main(opt):
    e_conn = ec2.connect_to_region(opt.region)
    f = {"tag:service": opt.service, "tag:version": opt.version}
    for x in e_conn.get_all_images(owners="self", filters=f):
        sys.stdout.write(x.id)
        break


if __name__ == '__main__':
    from optparse import OptionParser
    parser = OptionParser()
    parser.add_option('--region')
    parser.add_option('--service')
    parser.add_option('--version')
    opt, arg = parser.parse_args()

    main(opt)

