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

import argparse
from collections.abc import Iterable
from typing import Any


class TypedArgs:
    '''Simple argparse wrapper to give us type annotations on the parsed
    arguments.  The caller subclasses this class, defines fields on it, then
    configures and runs argparse.ArgumentParser via instance methods.  The
    methods cross-check the field types with the configuration given to
    argparse.  This ensures argparse doesn't get out of sync with the field
    types, without needing to implement automatic translation from field
    types to argparse (which could cause subtle problems if buggy).

    The implementation doesn't try to be comprehensive.  If you start using
    a new argparse feature, you'll probably have to extend this.'''

    def __init__(self, *args: Any, **kwargs: Any):
        self.parser = argparse.ArgumentParser(*args, **kwargs)
        self._unprocessed_fields = {k for k in self.__annotations__.keys()}

    def add_arg(
        self,
        *args: Any,
        parser: argparse.ArgumentParser | None = None,
        **kwargs: Any,
    ) -> None:
        # calculate field name and whether None is an allowed value
        expected_bool = kwargs.get('action') in ('store_true', 'store_false')
        for arg in args:
            if arg.startswith('--'):
                # option
                field: str = arg.lstrip('-').replace('-', '_')
                expected_none_forbidden = (
                    True if expected_bool else kwargs.get('required', False)
                )
                break
            elif not arg.startswith('-'):
                # positional parameter
                field = arg.replace('-', '_')
                expected_none_forbidden = kwargs.get('required', True)
                break
        else:
            raise ValueError(f'Option name not found in "{args}"')
        if 'dest' in kwargs:
            # field name overridden
            field = kwargs['dest']
        if kwargs.get('default') is not None:
            expected_none_forbidden = True

        # calculate expected field type
        typ = kwargs.get('type', str)
        if isinstance(typ, argparse.FileType):
            if 'b' in typ._mode:
                expected_type = 'BinaryIO'
            else:
                expected_type = 'TextIO'
        elif expected_bool:
            expected_type = 'bool'
        else:
            expected_type = typ.__name__
        nargs: str | int | None = kwargs.get('nargs')
        if nargs in {'*', '+'} or type(nargs) is int:
            expected_type = f'list[{expected_type}]'

        # calculate actual field type and requiredness
        annotation = self.__annotations__.get(field)
        if annotation is None:
            raise AttributeError(f'TypedArgs has no field "{field}"')
        anno_types = {a.strip() for a in annotation.split('|')}
        try:
            # "| None" -> optional field
            anno_types.remove('None')
            anno_none_forbidden = False
        except KeyError:
            anno_none_forbidden = True
        if len(anno_types) != 1:
            # field allows only None, or 2+ things besides None
            raise AttributeError(f'Could not parse types for field "{field}"')
        anno_type = anno_types.pop()

        # do checks
        if anno_type != expected_type:
            raise TypeError(
                f'TypedArgs field "{field}" type "{anno_type}" != "{expected_type}"'  # noqa: E501
            )
        if anno_none_forbidden != expected_none_forbidden:
            raise TypeError(
                f'TypedArgs field "{field}" forbids None "{anno_none_forbidden}" != "{expected_none_forbidden}"'  # noqa: E501
            )

        # mark the field processed.  allow a field to be processed multiple
        # times on different subparsers.
        self._unprocessed_fields.discard(field)

        # set up the actual argument
        (parser or self.parser).add_argument(*args, **kwargs)

    def parse(self, allow_extra_fields: Iterable[str] | None = None) -> None:
        unprocessed = self._unprocessed_fields - set(allow_extra_fields or [])
        if unprocessed:
            raise ValueError(f'Unused fields: {unprocessed}')
        self.parser.parse_args(namespace=self)
