#!/usr/bin/env bash

# A place to try out random bash commands

# echo "HI"

# HELLO="Hello"
# HELLO_WORLD="$HELLO world"

# echo "$HELLO world"
# echo "$HELLO_WORLD"
# echo '$HELLO_WORLD'
# echo '"$HELLO_WORLD"'

# command_array=("Hello" "$HELLO world" "$HELLO_WORLD")

# for i in "${command_array[@]}"; do
#     echo $i
#     echo "$i" | grep '\$'
# done
SCRIPT=$0
ARGS=("$@")
function do() {

}

function --help() {
    _default_params
    _define_commands
    echo "Help!"
    printf "\nRunning the following commands:"
    echo
    for i in "${COMMANDS[@]}"; do
        printf "\n\t$i"
    done

}
function _run_commands() {
    _define_params
    _define_commands
    for i in "${COMMANDS[@]}"; do
        eval $i
    done
}
function _define_params() {
    : ${ARGS[1]?"Missing a required command line argument. run '$SCRIPT --help' for usage instructions."}
    PATH_IN=$(realpath ${ARGS[1]})
}
function _default_params() {
    PATH_IN="PATH_IN"
}
function dry_run() {
    _define_params
    _define_commands

    echo "Dry run for $SCRIPT"
    echo
    echo "These are the commands that would be executed."
    for i in "${COMMANDS[@]}"; do
        echo $i
    done

}
function _define_commands() {
    COMMANDS=(
        "echo 'Action_1'"
        "echo 'Action_2'"
        "ls -la $PATH_IN"
    )
}
# Runs the help function if no arguments given to script.
TIMEFORMAT=$'\nTask completed in %3lR'
time "${@:---help}"
################### No code below this line #####################
