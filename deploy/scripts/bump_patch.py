#!/usr/bin/env python
import sys
import semantic_version
import json
import os

def bump(_config):
    with open(_config, 'r') as config:
        d = json.loads(config.read())
    v = semantic_version.Version(d.get("variables").get("version"))
    d["variables"]["version"] = str(v.next_patch())
    with open(_config, "w") as config:
        config.write(json.dumps(d, separators=(',', ':'), indent=4))

def sanitize_path(path):
    path = os.path.expandvars(path)
    path = os.path.expanduser(path)
    path = os.path.abspath(path)
    return path

if __name__ == '__main__':
    from optparse import OptionParser
    p = OptionParser()
    p.add_option('--config')
    opt, arg = p.parse_args()
    config_path = sanitize_path(opt.config)
    if not os.path.isfile(config_path):
        sys.stderr.write("Could not find config file:{0}\n".format(config_path))
        sys.exit(1)
    try:
        bump(config_path)
        sys.exit(0)
    except Exception, e:
        sys.stderr.write(str(e))
        sys.stderr.flush()
        sys.exit(1)
