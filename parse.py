#!/usr/bin/env python
# -*- coding: utf-8 -*-

from collections import defaultdict
from datetime import datetime
from glob import glob
import json
import os
import re

from git.config import GitConfigParser
from jinja2 import Template

current_dir = os.path.dirname(os.path.realpath(__file__))
index_html = os.path.join(current_dir, 'public/index.html')
index_tmp = os.path.join(current_dir, 'index.tmp')
extra_json = os.path.join(current_dir, 'extra.json')
base_url = 'https://github.com/getpelican/pelican-themes/tree/master/'
images = defaultdict(set)
themes = {}
os.chdir(os.path.join(current_dir, 'public'))


def parse_submodules(path):
    config = GitConfigParser(path)
    submodules = {}
    for section in config.sections():
        d = dict(config.items(section))
        submodules[d['path']] = d['url']
    return submodules

for dir_name in glob('data/pelican-themes/*/'):
    dir_name = os.path.basename(os.path.split(dir_name)[0])
    images[dir_name] = set()

for png in (glob('data/pelican-themes/*/*.png')
            + glob('data/pelican-themes/*/*.gif')
            + glob('data/pelican-themes/*/*.jpg')
            + glob('data/pelican-themes/*/*.jpeg')
            + glob('data/pelican-themes/*/screenshots/*.png')
            ):
    dir_name = os.path.basename(os.path.split(png)[0])
    images[dir_name].add(png)

submodules = parse_submodules('data/pelican-themes/.gitmodules')

for key, value in images.iteritems():
    value = list(value)
    if key in submodules:
        themes[key] = {
            'name': key,
            'url': submodules[key],
            'screenshots': value,
        }
    else:
        themes[key] = {
            'name': key,
            'url': base_url + key,
            'screenshots': value,
        }

with open(extra_json) as f:
    themes.update(json.loads(f.read()))
for key, value in themes.items():
    url = value['url'].rstrip('.git')
    if url.startswith('git://'):
        url = 'https://' + url.split('git://')[1]
    elif url.startswith('git@'):
        url = re.sub(r'git@([^:]+):([^/]+)/(.+)', r'https://\1/\2/\3', url)
    themes[key]['url'] = url

print len(themes)
with open(index_tmp) as f:
    html = Template(f.read()).render(themes=themes, now=datetime.now())
    with open(index_html, 'w') as f2:
        f2.write(html)
