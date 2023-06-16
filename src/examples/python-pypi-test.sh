#!/usr/bin/env bash

# This script is based on: https://github.com/adriancooney/Taskfile
# HOME: https://github.com/DonalChilde/bash-task

# Upload a package to PyPi Test

# -e Exit immediately if a pipeline returns a non-zero status.
# -u Treat unset variables and parameters other than the special parameters ‘@’ or ‘*’ as an error when performing parameter expansion.
# -o pipefail If set, the return value of a pipeline is the value of the last (rightmost) command to exit with a non-zero status, or zero if all commands in the pipeline exit successfully.
set -euo pipefail

# Define non-parameter variables here.
# The name of the script
SCRIPT=$0
# The script command line arguments as an array
ARGS=("$@")

# The location of the .pypirc file relative to the project root.
PYPIRC_RELATIVE="secrets/.pypirc"
# The location of the dist directory relative to the project root.
DIST_DIR_RELATIVE="dist/"

function do() {
    # Choose with or without confirmation

    # With confirmation before execution. This will also display the list of commands.
    # Pass in the number of seconds to delay confirmation of commands.
    _do_with_confirmation 5

    # Without confirmation before execution
    # _do_without_confirmation
}

function _define_commands() {
    # Define the commands used in this script.

    # Parameters passed in from the command line are generally assigned
    # to variables in the `_define_variables` function. These variables are then used in
    # the commands. This makes it easier to have a display of the commands in the `--help` function
    # with placeholder names for the CLI parameters.
    COMMANDS=(
        "twine check --strict '$DIST_DIR/*'"
        "twine upload --config-file '$PYPIRC' --repository testpypi '$DIST_DIR/*'"
    )
}

function _define_placeholder_variables() {
    # Define the command variables to be used in the help output.
    PATH_IN="PATH_IN"
    # PATH_OUT="PATH_OUT
    DIST_DIR="PATH_IN/DIST_DIR_RELATIVE"
    PYPIRC="PATH_IN/PYPIRC_RELATIVE"
}

function _define_variables() {
    # Check for correct parameters passed in, and assign to variables to be used in commands.

    # Checks for the presence of an parameter, but not validity. Output help if missing.
    # https://stackoverflow.com/a/25066804
    # Arguments start at 1, as 0 is the `do` or `dry-run` command.
    : ${ARGS[1]?"Missing a required command line argument. run '$SCRIPT --help' for usage instructions."}
    # : ${ARGS[2]?"Missing a required command line argument. run '$SCRIPT help' for usage instructions."}

    # Check for cli arguments in excess of action command - ie. `do` or `dry-run`
    # EXCESS_ARGS=("${ARGS[@]:1}")
    # if [ ${#EXCESS_ARGS[@]} -eq 0 ]; then
    #     # Set default arguments for CODE_PATHS
    #     CODE_PATHS=(./src ./tests)
    # else
    #     CODE_PATHS=(${EXCESS_ARGS[@]})
    # fi

    # Assign variables used in the commands
    # A variable with a default value:
    #   PATH_IN=${ARGS[1]:-"./foo/bar"}
    PATH_IN=$(realpath ${ARGS[1]})
    # PATH_OUT=$(realpath ${ARGS[2]})

    DIST_DIR="$PATH_IN/$DIST_DIR_RELATIVE"
    PYPIRC="$PATH_IN/$PYPIRC_RELATIVE"

}

function _do_without_confirmation() {

    echo "Running Commands"
    echo
    echo
    _run_commands
}

function _do_with_confirmation() {

    echo "This will run the following commands:"
    echo
    dry-run
    echo

    echo "Preparing to upload to PyPi."
    echo "Did you:"
    echo "\t- Check for the correct branch?"
    echo "\t- Update the version number?"
    echo "\t- Update the documentation?"
    echo "\t- Run ALL THE TESTS?"
    echo "\t- Update the changelog?"
    echo "\t- Build a fresh dist/?"
    echo

    # Delay message
    echo "Take $1 seconds to be sure:"
    echo
    _countdown $1
    echo

    # Confirmation dialog
    # https://stackoverflow.com/a/1885534/105844
    read -p "-----Are you sure? (Y/N)-----" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        _run_commands
    else
        echo "Commands Declined"
        exit 1
    fi
}

function _run_commands() {
    _define_variables
    _define_commands

    for i in "${COMMANDS[@]}"; do
        eval $i
    done
}

function dry-run() {
    _define_variables
    _define_commands

    echo "Dry run for $SCRIPT"
    echo
    echo "These are the commands that would be executed."
    echo
    for i in "${COMMANDS[@]}"; do
        echo $i
    done
}

function --help() {
    _define_placeholder_variables
    _define_commands

    HELPTEXT=$(
        cat <<END
    NAME
        $SCRIPT - Upload a package to PyPi.

    SYNOPSIS
        $SCRIPT do PARAMETERS
        $SCRIPT dry-run PARAMETERS
        $SCRIPT --help

    DESCRIPTION
        Uses twine to check and upload a package to PyPI.

    EXAMPLES:
        $SCRIPT do PARAMETERS
            Do the script.

        $SCRIPT dry-run PARAMETERS
            Display the commands that would be run, takes the same paramaters as do.

        $SCRIPT --help
            Output the usage instructions.

    COMMANDS:

END
    )
    printf "$HELPTEXT"
    echo
    for i in "${COMMANDS[@]}"; do
        printf "\n\t$i"
    done
    echo
}

function _countdown() {
    # https://superuser.com/questions/611538/is-there-a-way-to-display-a-countdown-or-stopwatch-timer-in-a-terminal
    # Display a countdown clock.
    # $1 = int seconds
    date1=$(($(date +%s) + $1))
    while [ "$date1" -ge $(date +%s) ]; do
        echo -ne "$(date -u --date @$(($date1 - $(date +%s))) +%H:%M:%S)\r"
        sleep 0.1
    done
}

# Runs the help function if no arguments given to script.
TIMEFORMAT=$'\nTask completed in %3lR'
time "${@:---help}"
################### No code below this line #####################
