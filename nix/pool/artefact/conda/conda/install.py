# (c) 2012-2014 Continuum Analytics, Inc. / http://continuum.io
# All Rights Reserved
#
# conda is distributed under the terms of the BSD 3-clause license.
# Consult LICENSE.txt or http://opensource.org/licenses/BSD-3-Clause.
""" This module contains:
  * all low-level code for extracting, linking and unlinking packages
  * a very simple CLI

These API functions have argument names referring to:

    dist:        canonical package name (e.g. 'numpy-1.6.2-py26_0')

    pkgs_dir:    the "packages directory" (e.g. '/opt/anaconda/pkgs' or
                 '/home/joe/envs/.pkgs')

    prefix:      the prefix of a particular environment, which may also
                 be the "default" environment (i.e. sys.prefix),
                 but is otherwise something like '/opt/anaconda/envs/foo',
                 or even any prefix, e.g. '/home/joe/myenv'
"""
from __future__ import absolute_import, division, print_function, unicode_literals

from errno import EACCES, EEXIST, ENOENT, EPERM, EROFS
import functools
import logging
import os
from os import chmod, makedirs, stat
from os.path import (dirname, isdir, isfile, join, normcase, normpath)
import re
from textwrap import dedent

from .base.constants import PREFIX_PLACEHOLDER
from .common.compat import on_win
from .gateways.disk.delete import delete_trash, move_path_to_trash, rm_rf
delete_trash, move_path_to_trash = delete_trash, move_path_to_trash
from .core.linked_data import is_linked, linked, linked_data  # NOQA
is_linked, linked, linked_data = is_linked, linked, linked_data
from .core.package_cache import rm_fetched  # NOQA
rm_fetched = rm_fetched

log = logging.getLogger(__name__)
stdoutlog = logging.getLogger('stdoutlog')

# backwards compatibility for conda-build
prefix_placeholder = PREFIX_PLACEHOLDER

# backwards compatibility for conda-build
def package_cache():
    from .core.package_cache import package_cache
    return package_cache()


if on_win:
    def win_conda_bat_redirect(src, dst, shell):
        """Special function for Windows XP where the `CreateSymbolicLink`
        function is not available.

        Simply creates a `.bat` file at `dst` which calls `src` together with
        all command line arguments.

        Works of course only with callable files, e.g. `.bat` or `.exe` files.
        """
        # ensure that directory exists first
        try:
            makedirs(dirname(dst))
        except OSError as exc:  # Python >2.5
            if exc.errno == EEXIST and isdir(dirname(dst)):
                pass
            else:
                raise

        # bat file redirect
        if not isfile(dst + '.bat'):
            with open(dst + '.bat', 'w') as f:
                f.write(dedent("""\
                    @echo off
                    call "{}" %%*
                    """).format(src))

        # TODO: probably need one here for powershell at some point

    def win_conda_unix_redirect(src, dst, shell):
        """Special function for Windows where the os.symlink function
        is unavailable due to a lack of user priviledges.

        Simply creates a source-able intermediate file.
        """
        # ensure that directory exists first
        try:
            os.makedirs(os.path.dirname(dst))
        except OSError as exc:  # Python >2.5
            if exc.errno == EEXIST and os.path.isdir(os.path.dirname(dst)):
                pass
            else:
                raise

        from conda.utils import shells
        # technically these are "links" - but for obvious reasons
        # os.path.islink wont work
        if not isfile(dst):
            with open(dst, "w") as f:
                shell_vars = shells[shell]

                # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                # !! ensure the file ends with a blank line this is       !!
                # !! critical for Windows support                         !!
                # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

                # conda is used as an executable
                if src.endswith("conda"):
                    command = shell_vars['path_to'](src+".exe")
                    text = dedent("""\
                        #!/usr/bin/env {shebang}
                        {command} {allargs}
                        """).format(
                        shebang=re.sub(
                            r'\.\w+$',
                            r'',
                            os.path.basename(shell_vars["exe"])),
                        command=command,
                        **shell_vars)
                    f.write(text)
                # all others are used as sourced
                else:
                    command = shell_vars["source"].format(shell_vars['path_to'](src))
                    text = dedent("""\
                        #!/usr/bin/env {shebang}
                        {command} {allargs}
                        """).format(
                        shebang=re.sub(
                            r'\.\w+$',
                            r'',
                            os.path.basename(shell_vars["exe"])),
                        command=command,
                        **shell_vars)
                    f.write(text)

            # Make the new file executable
            # http://stackoverflow.com/a/30463972/1170370
            mode = stat(dst).st_mode
            mode |= (mode & 292) >> 2    # copy R bits to X
            chmod(dst, mode)


# Should this be an API function?
def symlink_conda(prefix, root_dir, shell=None):
    # do not symlink root env - this clobbers activate incorrectly.
    # prefix should always be longer than, or outside the root dir.
    if normcase(normpath(prefix)) in normcase(normpath(root_dir)):
        return

    if shell is None:
        shell = "bash.msys"

    if on_win:
        where = 'Scripts'
    else:
        where = 'bin'

    if on_win:
        if shell in ["cmd.exe", "powershell.exe"]:
            symlink_fn = functools.partial(win_conda_bat_redirect, shell=shell)
        else:
            symlink_fn = functools.partial(win_conda_unix_redirect, shell=shell)
    else:
        symlink_fn = os.symlink

    if not isdir(join(prefix, where)):
        os.makedirs(join(prefix, where))
    symlink_conda_hlp(prefix, root_dir, where, symlink_fn)


def symlink_conda_hlp(prefix, root_dir, where, symlink_fn):
    scripts = ["conda", "activate", "deactivate"]
    prefix_where = join(prefix, where)
    if not isdir(prefix_where):
        os.makedirs(prefix_where)
    for f in scripts:
        root_file = join(root_dir, where, f)
        prefix_file = join(prefix_where, f)
        try:
            # try to kill stale links if they exist
            if os.path.lexists(prefix_file):
                rm_rf(prefix_file)

            # if they're in use, they won't be killed, skip making new symlink
            if not os.path.lexists(prefix_file):
                symlink_fn(root_file, prefix_file)
        except (IOError, OSError) as e:
            if (os.path.lexists(prefix_file) and (e.errno in [EPERM, EACCES, EROFS, EEXIST])):
                log.debug("Cannot symlink {0} to {1}. Ignoring since link already exists."
                          .format(root_file, prefix_file))
            elif e.errno == ENOENT:
                log.debug("Problem with symlink management {0} {1}. File may have been removed by "
                          "another concurrent process." .format(root_file, prefix_file))
            elif e.errno == EEXIST:
                log.debug("Problem with symlink management {0} {1}. File may have been created by "
                          "another concurrent process." .format(root_file, prefix_file))
            else:
                raise
