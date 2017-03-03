#!/bin/bash
# NOTE: this script should be sourced instead of executed


travis_build_and_upload() {
    if [[ "$TRAVIS_BRANCH" == master && "$TRAVIS_PULL_REQUEST" == false ]]; then
        set -e
        conda install -y conda-build anaconda-client
        conda build --python $PY_VERSION conda.recipe | tee build.log
        local tarball="$(grep 'anaconda upload' build.log | tail -1 | cut -d' ' -f5)"
        echo "uploading..."
        echo " > anaconda upload --user conda --label dev $tarball"
        anaconda --token $ANACONDA_TOKEN upload --user conda --label dev "$tarball"
    fi
}


travis_bootstrap_conda() {
    local py_major=${PY_VERSION:0:1}

    if ! [[ -d $HOME/miniconda ]]; then
        declare miniconda_url
        case "$(uname -s | tr '[:upper:]' '[:lower:]')" in
            linux) miniconda_url="https://repo.continuum.io/miniconda/Miniconda${py_major}-latest-Linux-x86_64.sh";;
            darwin) miniconda_url="https://repo.continuum.io/miniconda/Miniconda${py_major}-latest-MacOSX-x86_64.sh";;
        esac

        curl -sS -o miniconda.sh "$miniconda_url"
        bash miniconda.sh -bfp $HOME/miniconda
        rm -rf miniconda.sh
    fi

    export PATH="$HOME/miniconda/bin:$PATH"
    hash -r
    conda config --set always_yes yes
    conda update -q conda

    # TODO: on hold until we get virtualenvs working
    # declare python_version
    # case "$TOXENV" in
    #     py27) python_version="2.7";;
    #     py33) python_version="3.3";;
    #     py34) python_version="3.4";;
    #     py35) python_version="3.5";;
    #     *)    python_version="3.5";;
    # esac

    # conda create -q -n test-environment python="$python_version" setuptools pip virtualenv
    # source activate test-environment

    conda info --all
    conda list
    rvm get head
}

travis_bootstrap_conda
