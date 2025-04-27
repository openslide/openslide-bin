#
# Tools for building OpenSlide and its dependencies
#
# Copyright (c) 2023 Benjamin Gilbert
# All rights reserved.
#
# This script is free software: you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License, version 2.1,
# as published by the Free Software Foundation.
#
# This script is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License
# for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this script. If not, see <http://www.gnu.org/licenses/>.
#

from __future__ import annotations

from email.message import Message
from email.policy import Compat32
import tomllib

from .meson import meson_source_root


def pyproject_to_message(pyproject: str) -> Message:
    meta = tomllib.loads(pyproject)
    out = Message(policy=Compat32(max_line_length=None))
    out['Metadata-Version'] = '2.3'
    for k, v in meta['project'].items():
        k = k.lower()
        if k == 'name':
            out['Name'] = v
        elif k == 'version':
            out['Version'] = v
        elif k == 'description':
            out['Summary'] = v
        elif k == 'readme':
            out.set_payload((meson_source_root() / v).read_bytes())
            if v.lower().endswith('.md'):
                out['Description-Content-Type'] = 'text/markdown'
        elif k == 'keywords':
            out['Keywords'] = ','.join(v)
        elif k == 'urls':
            for kk, vv in v.items():
                kk = kk.lower()
                if kk == 'homepage':
                    out['Home-page'] = vv
                elif kk == 'release notes':
                    out['Project-URL'] = f'Release notes, {vv}'
                elif kk == 'repository':
                    out['Project-URL'] = f'Repository, {vv}'
                else:
                    raise Exception(f'Unknown URL type: {kk}')
        elif k == 'authors':
            for item in v:
                out['Author-Email'] = f'{item["name"]} <{item["email"]}>'
        elif k == 'maintainers':
            for item in v:
                out['Maintainer-Email'] = f'{item["name"]} <{item["email"]}>'
        elif k == 'license':
            out['License'] = v.pop('text')
            assert not v
        elif k == 'classifiers':
            for vv in v:
                out['Classifier'] = vv
        elif k == 'requires-python':
            out['Requires-Python'] = v
        else:
            raise Exception(f'Unknown field: {k}')
    return out
