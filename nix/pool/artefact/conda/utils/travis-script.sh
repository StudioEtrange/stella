#!/usr/bin/env bash
# NOTE: this script should be sourced instead of executed

# turn ON immediate error termination
set -e
# turn OFF verbose printing of commands/results
set +x

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# #                                                                     # #
# # TRAVIS CI SCRIPT                                                    # #
# #                                                                     # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

###########################################################################
# HELPER FUNCTIONS                                                        #
main_test() {
    echo "MAIN TEST"

    PYTHONHASHSEED=$(python -c "import random as r; print(r.randint(0,4294967296))")
    export PYTHONHASHSEED
    echo "${PYTHONHASHSEED}"

    # detect what shells are available to test with
    # refer to conda.util.shells for appropriate syntaxes
    # don't bother testing for the default shell `sh`, generally speaking the default
    # shell will be supported if it's one of the supported shells
    shells=""
    [[ $(which bash) ]] && shells="${shells} --shell=bash"
    [[ $(which dash) ]] && shells="${shells} --shell=dash"
    [[ $(which posh) ]] && shells="${shells} --shell=posh"
    [[ $(which zsh) ]]  && shells="${shells} --shell=zsh"
    [[ $(which ksh) ]]  && shells="${shells} --shell=ksh"
    [[ $(which csh) ]]  && shells="${shells} --shell=csh"
    [[ $(which tcsh) ]] && shells="${shells} --shell=tcsh"
    echo "TESTING ON SHELLS: ${shells}"

    python -m pytest --cov-report xml ${shells} -m "not installed" tests

    # `develop` instead of `install` to avoid coverage issues of tracking two
    # separate "codes"
    python setup.py --version
    python setup.py develop
    hash -r
    python -m conda info

    python -m pytest --cov-report xml --cov-append ${shells} -m "installed" tests

    echo "END MAIN TEST"
}


flake8_test() {
    echo "FLAKE8 TEST"

    python -m flake8 --statistics

    echo "END FLAKE8 TEST"
}


conda_build_smoke_test() {
    echo "CONDA BUILD SMOKE TEST"

    conda config --add channels conda-canary

    # this conda build uses conda's own conda.recipe
    conda build conda.recipe

    # this conda build uses conda_build_test_recipe's (retrieved via a git
    # clone in the install process) own conda.recipe
    # conda build conda_build_test_recipe/conda.recipe

    echo "END CONDA BUILD SMOKE TEST"
}


conda_build_unit_test() {
    echo "CONDA BUILD UNIT TEST"

    # ignore any errors produced by py.test
    # since we are running with -e all commands will terminate if they
    # return a non-zero exit code, this can be countered by capturing
    # the return code in a conditional clause, then we need to deal with
    # the exit code of the conditional clause
    pushd conda-build
    echo
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
    echo ">>>>>>>>>>>>>>>>>>> conda-build py.test start <<<<<<<<<<<<<<<<<<"
    echo
    python -m pytest -n 2 --basetemp /tmp/cb tests || PYTEST_STATUS=$?
    echo
    echo ">>>>>>>>>>>> conda-build py.test exited with code $PYTEST_STATUS <<<<<<<<<<<"
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
    echo
    unset PYTEST_STATUS
    popd

    echo "END CONDA BUILD UNIT TEST"
}
# END HELPER FUNCTIONS                                                    #
###########################################################################

###########################################################################
# MAIN FUNCTION                                                           #
echo "START SCRIPT"

# show basic environment details                                          #
which -a python
env | sort

# remove duplicates from the $PATH                                        #
# CSH has issues when variables get too long                              #
# a common error that may occur would be a "Word too long" error and is   #
# probably related to the PATH variable, here we use envvar_cleanup.bash  #
# to remove duplicates from the path variable before trying to run the    #
# tests                                                                   #
PATH=$(./shell/envvar_cleanup.bash "$PATH" -d)
export PATH

# perform the appropriate test setup                                      #
if [[ "${FLAKE8}" == true ]]; then
    flake8_test
elif [[ -n "${CONDA_BUILD}" ]]; then
    # running anything with python -m conda in Miniconda3 4.0.5 causes
    # issues, use conda directly
    conda_build_smoke_test
    conda_build_unit_test
else
    main_test
fi

echo "DONE SCRIPT"
# END MAIN FUNCTION                                                       #
###########################################################################
