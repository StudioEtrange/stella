# -*- coding: utf-8 -*-
from __future__ import absolute_import, division, print_function, unicode_literals

import os
import pytest
from errno import ENOENT
from os.path import join, isdir, islink, lexists, isfile
from conda.base.context import context
from conda.gateways.disk.delete import rm_rf, move_to_trash
from conda.gateways.disk.update import touch
from conda.gateways.disk.link import islink
from test_permissions import tempdir, _try_open, _make_read_only
from conda.utils import on_win


def can_not_symlink():
    return on_win and context.default_python[0] == '2'


def _write_file(path, content):
    with open(path, "a") as fh:
        fh.write(content)
        fh.close()


def test_remove_file():
    with tempdir() as td:
        test_path = join(td, 'test_path')
        touch(test_path)
        assert isfile(test_path)
        _try_open(test_path)
        _make_read_only(test_path)
        pytest.raises((IOError, OSError), _try_open, test_path)
        assert rm_rf(test_path)
        assert not isfile(test_path)


def test_remove_file_to_trash():
    with tempdir() as td:
        test_path = join(td, 'test_path')
        touch(test_path)
        assert isfile(test_path)
        _try_open(test_path)
        _make_read_only(test_path)
        pytest.raises((IOError, OSError), _try_open, test_path)
        assert rm_rf(test_path)
        assert not isfile(test_path)


def test_remove_dir():
    with tempdir() as td:
        test_path = join(td, 'test_path')
        touch(test_path)
        _try_open(test_path)
        assert isfile(test_path)
        assert isdir(td)
        assert not islink(test_path)
        assert rm_rf(td)
        assert rm_rf(test_path)
        assert not isdir(td)
        assert not isfile(test_path)
        assert not lexists(test_path)


@pytest.mark.skipif(can_not_symlink(), reason="symlink function not available")
def test_remove_link_to_file():
    with tempdir() as td:
        dst_link = join(td, "test_link")
        src_file = join(td, "test_file")
        _write_file(src_file, "welcome to the ministry of silly walks")
        os.symlink(src_file, dst_link)
        assert isfile(src_file)
        assert not islink(src_file)
        assert islink(dst_link)
        assert rm_rf(dst_link)
        assert isfile(src_file)
        assert rm_rf(src_file)
        assert not isfile(src_file)
        assert not islink(dst_link)
        assert not lexists(dst_link)


@pytest.mark.skipif(can_not_symlink(), reason="symlink function not available")
def test_remove_link_to_dir():
    with tempdir() as td:
        dst_link = join(td, "test_link")
        src_dir = join(td, "test_dir")
        _write_file(src_dir, "welcome to the ministry of silly walks")
        os.symlink(src_dir, dst_link)
        assert not islink(src_dir)
        assert islink(dst_link)
        assert rm_rf(dst_link)
        assert not isdir(dst_link)
        assert not islink(dst_link)
        assert rm_rf(src_dir)
        assert not isdir(src_dir)
        assert not islink(src_dir)
        assert not lexists(dst_link)


def test_move_to_trash():
    with tempdir() as td:
        test_path = join(td, 'test_path')
        touch(test_path)
        _try_open(test_path)
        assert isdir(td)
        assert isfile(test_path)
        move_to_trash(td, test_path)
        assert not isfile(test_path)


def test_move_path_to_trash_couldnt():
    from conda.gateways.disk.delete import move_path_to_trash
    with tempdir() as td:
        test_path = join(td, 'test_path')
        touch(test_path)
        _try_open(test_path)
        assert isdir(td)
        assert isfile(test_path)
        assert move_path_to_trash(test_path)


def test_backoff_unlink():
    from conda.gateways.disk.delete import backoff_rmdir
    with tempdir() as td:
        test_path = join(td, 'test_path')
        touch(test_path)
        _try_open(test_path)
        assert isdir(td)
        backoff_rmdir(td)
        assert not isdir(td)


def test_backoff_unlink_doesnt_exist():
    from conda.gateways.disk.delete import backoff_rmdir
    with tempdir() as td:
        test_path = join(td, 'test_path')
        touch(test_path)
        try:
            backoff_rmdir(join(test_path, 'some', 'path', 'in', 'utopia'))
        except Exception as e:
            assert e.value.errno == ENOENT


def test_try_rmdir_all_empty_doesnt_exist():
    from conda.gateways.disk.delete import try_rmdir_all_empty
    with tempdir() as td:
        assert isdir(td)
        try_rmdir_all_empty(td)
        assert not isdir(td)
