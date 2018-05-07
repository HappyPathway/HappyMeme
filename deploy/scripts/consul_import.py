#!/usr/bin/env python2.7
import consul
import json
from glob import glob
import os
import sys
import copy
import warnings
from functools import partial
warnings.filterwarnings("ignore")

# since we should allow False as a value for a key, we will set a random string
# if the output of module.params.get("value") == random_string,
# then we know we didn't pass a value
RAND_STR = "AoCFb2Da5hMmmvemkMmS"


def consul_import(c, import_file, key, dc):

    with open(import_file, 'r') as j_data:
        data = json.loads(j_data.read())

    data_copy = copy.deepcopy(data)
    for k, v in data_copy.items():
        if '/' in k:
            if key:
                path = os.path.join(key, k)
            else:
                path = k
            print path, v, dc
            consul_write(c, path, json.dumps(v), dc)
            data.pop(k)

    print data
    if data.keys():
        consul_write(c, key, json.dumps(data), dc)


def consul_write(c, key, data, dc):
    c.kv.put(key, data, dc=dc)

def main(opt, args):
    _host   = opt.host
    _dc     = opt.dc
    _token  = opt.token
    _scheme = opt.scheme
    _verify = opt.verify
    _key    = opt.key
    _value  = opt.value
    _delete = opt.delete

    # connect to consul
    # c = consul.Consul(host=_host, token=_token, scheme=_scheme, verify=_verify, dc=_dc)
    consul_client = partial(consul.Consul, host=_host, scheme=_scheme, verify=_verify, dc=_dc)
    # we may have not setup ACLs and tokens, still want to be able to use this script.
    if opt.token:
        consul_client = partial(consul_client, token=_token)
    c = consul_client()
    if opt.delete:
      data = c.kv.delete(_key, recurse=opt.recursive)
      sys.exit(1)

    if _value or args:
    	try:
            if not args:
                consul_write(c, _key, _value, dc=_dc)
            elif not opt.consul_import:
                with open(args[0], 'r') as d_file:
                    d = json.loads(d_file.read())
                    d_str = json.dumps(d)
                    consul_write(c, _key, d_str, dc=_dc)
    	except Exception, e:
            sys.stderr.write(str(e))
            sys.stderr.write("\nCould not set key: {0} value: {1}\n".format(_key, _value))

    elif opt.consul_import:
        consul_import(c, opt.consul_import, _key, _dc)

    else:
    	try:
            data = c.kv.get(_key, recurse=opt.recursive)
            if not opt.recursive:
                _value = data[1].get("Value")
                print json.dumps(_value, separators=(',', ':'), indent=4, sort_keys=True)
            else:
                returned_data = []
                useable_data = data[1]
                d = dict()
                for k in useable_data:
                    try:
                        d[k.get('Key')] = json.loads(k.get('Value'))
                    except:
                        d[k.get('Key')] = k.get('Value')
                print json.dumps(d, separators=(',', ':'), indent=4, sort_keys=True)
    	except Exception, e:
            #sys.stderr.write(str(e))
            sys.stderr.write("\nCould not get key: {0}\n".format(_key))


if __name__ == '__main__':
    from optparse import OptionParser, OptionGroup
    parser = OptionParser()
    server_group = OptionGroup(parser, "Consul Server Connection Options")
    server_group.add_option('--host', default="consul.ops.happypathway.com")
    server_group.add_option('--token', default=os.environ.get('CONSUL_TOKEN'))
    server_group.add_option('--dc', default='dc1')
    server_group.add_option('--scheme', default='http')
    server_group.add_option('--verify', default=False, action='store_true')
    parser.add_option_group(server_group)

    value_group = OptionGroup(parser, "Consul K/V Options")
    value_group.add_option('--key')
    value_group.add_option('--value')
    value_group.add_option('--delete', default=False, action='store_true')
    value_group.add_option('--import', dest='consul_import', default=False)
    value_group.add_option('--recursive', default=False, action='store_true')
    parser.add_option_group(value_group)

    opt, args = parser.parse_args()
    main(opt, args)
