#!/usr/bin/env bash

# Constants
readonly project_name="ledstrip"

# Only enable these shell behaviours if we're not being sourced
# Approach via: https://stackoverflow.com/a/28776166/8787985
if ! (return 0 2> /dev/null); then
    # A better class of script...
    set -o errexit      # Exit on most errors (see the manual)
    set -o nounset      # Disallow expansion of unset variables
    set -o pipefail     # Use last non-zero exit code in a pipeline
fi

# Enable errtrace or the error trap handler will not work as expected
set -o errtrace         # Ensure the error trap handler is inherited

# DESC: Exit script with the given message
# ARGS: $1 (required): Message to print on exit
#       $2 (optional): Exit code (defaults to 0)
# OUTS: None
# RETS: None
# NOTE: The convention used in this script for exit codes is:
#       0: Normal exit
#       1: Abnormal exit due to external error
#       2: Abnormal exit due to script error
function script_exit() {
    if [[ $# -eq 1 ]]; then
        printf '%s\n' "$1"
        exit 0
    fi

    if [[ ${2-} =~ ^[0-9]+$ ]]; then
        printf '%b\n' "$1"
        # If we've been provided a non-zero exit code run the error trap
        if [[ $2 -ne 0 ]]; then
            script_trap_err "$2"
        else
            exit 0
        fi
    fi

    script_exit 'Missing required argument to script_exit()!' 2
}

# DESC: Generic script initialisation
# ARGS: $@ (optional): Arguments provided to the script
# OUTS: $orig_cwd: The current working directory when the script was run
#       $script_path: The full path to the script
#       $script_dir: The directory path of the script
#       $script_name: The file name of the script
#       $script_params: The original parameters provided to the script
#       $ta_none: The ANSI control code to reset all text attributes
# RETS: None
# NOTE: $script_path only contains the path that was used to call the script
#       and will not resolve any symlinks which may be present in the path.
#       You can use a tool like realpath to obtain the "true" path. The same
#       caveat applies to both the $script_dir and $script_name variables.
# shellcheck disable=SC2034
function script_init() {
    # Useful variables
    readonly orig_cwd="$PWD"
    readonly script_params="$*"
    readonly script_path="${BASH_SOURCE[0]}"
    script_dir="$(dirname "$script_path")"
    script_name="$(basename "$script_path")"
    readonly script_dir script_name

    # Important to always set as we use it in the exit handler
    # shellcheck disable=SC2155
    readonly ta_none="$(tput sgr0 2> /dev/null || true)"
}

# DESC: Initialise colour variables
# ARGS: None
# OUTS: Read-only variables with ANSI control codes
# RETS: None
# NOTE: If --no-colour was set the variables will be empty. The output of the
#       $ta_none variable after each tput is redundant during normal execution,
#       but ensures the terminal output isn't mangled when running with xtrace.
# shellcheck disable=SC2034,SC2155
function colour_init() {
    if [[ -z ${no_colour-} ]]; then
        # Text attributes
        readonly ta_bold="$(tput bold 2> /dev/null || true)"
        printf '%b' "$ta_none"
        readonly ta_uscore="$(tput smul 2> /dev/null || true)"
        printf '%b' "$ta_none"
        readonly ta_blink="$(tput blink 2> /dev/null || true)"
        printf '%b' "$ta_none"
        readonly ta_reverse="$(tput rev 2> /dev/null || true)"
        printf '%b' "$ta_none"
        readonly ta_conceal="$(tput invis 2> /dev/null || true)"
        printf '%b' "$ta_none"

        # Foreground codes
        readonly fg_black="$(tput setaf 0 2> /dev/null || true)"
        printf '%b' "$ta_none"
        readonly fg_blue="$(tput setaf 4 2> /dev/null || true)"
        printf '%b' "$ta_none"
        readonly fg_cyan="$(tput setaf 6 2> /dev/null || true)"
        printf '%b' "$ta_none"
        readonly fg_green="$(tput setaf 2 2> /dev/null || true)"
        printf '%b' "$ta_none"
        readonly fg_magenta="$(tput setaf 5 2> /dev/null || true)"
        printf '%b' "$ta_none"
        readonly fg_red="$(tput setaf 1 2> /dev/null || true)"
        printf '%b' "$ta_none"
        readonly fg_white="$(tput setaf 7 2> /dev/null || true)"
        printf '%b' "$ta_none"
        readonly fg_yellow="$(tput setaf 3 2> /dev/null || true)"
        printf '%b' "$ta_none"

        # Background codes
        readonly bg_black="$(tput setab 0 2> /dev/null || true)"
        printf '%b' "$ta_none"
        readonly bg_blue="$(tput setab 4 2> /dev/null || true)"
        printf '%b' "$ta_none"
        readonly bg_cyan="$(tput setab 6 2> /dev/null || true)"
        printf '%b' "$ta_none"
        readonly bg_green="$(tput setab 2 2> /dev/null || true)"
        printf '%b' "$ta_none"
        readonly bg_magenta="$(tput setab 5 2> /dev/null || true)"
        printf '%b' "$ta_none"
        readonly bg_red="$(tput setab 1 2> /dev/null || true)"
        printf '%b' "$ta_none"
        readonly bg_white="$(tput setab 7 2> /dev/null || true)"
        printf '%b' "$ta_none"
        readonly bg_yellow="$(tput setab 3 2> /dev/null || true)"
        printf '%b' "$ta_none"
    else
        # Text attributes
        readonly ta_bold=''
        readonly ta_uscore=''
        readonly ta_blink=''
        readonly ta_reverse=''
        readonly ta_conceal=''

        # Foreground codes
        readonly fg_black=''
        readonly fg_blue=''
        readonly fg_cyan=''
        readonly fg_green=''
        readonly fg_magenta=''
        readonly fg_red=''
        readonly fg_white=''
        readonly fg_yellow=''

        # Background codes
        readonly bg_black=''
        readonly bg_blue=''
        readonly bg_cyan=''
        readonly bg_green=''
        readonly bg_magenta=''
        readonly bg_red=''
        readonly bg_white=''
        readonly bg_yellow=''
    fi
}

# DESC: Check a binary exists in the search path
# ARGS: $1 (required): Name of the binary to test for existence
#       $2 (optional): Set to any value to treat failure as a fatal error
# OUTS: None
# RETS: 0 (true) if dependency was found, otherwise 1 (false) if failure is not
#       being treated as a fatal error.
function check_binary() {
    if [[ $# -lt 1 ]]; then
        script_exit 'Missing required argument to check_binary()!' 2
    fi

    if ! command -v "$1" > /dev/null 2>&1; then
        if [[ -n ${2-} ]]; then
            script_exit "Missing dependency: Couldn't locate $1." 1
        else
            verbose_print "Missing dependency: $1" "${fg_red-}"
            return 1
        fi
    fi

    verbose_print "Found dependency: $1"
    return 0
}

# DESC: Usage help
# ARGS: None
# OUTS: None
# RETS: None
function script_usage() {
    cat << EOF
Usage:
     -h|--help                  Displays this help.
     -a|--agent                 Path to AGENTS.md file.
     -x                         Displays verbose output
     -mcp                       Enable KiCad MCP server.
EOF
}

EN_MCP="0"

# DESC: Parameter parser
# ARGS: $@ (optional): Arguments provided to the script
# OUTS: Variables indicating command-line parameters and options
# RETS: None
function parse_params() {
    local param
    while [[ $# -gt 0 ]]; do
        param="$1"
        shift
        case $param in
            -h | --help)
                script_usage
                exit 0
                ;;
            -a | --agent)
                agent_file="${script_dir}/../$1"
                shift
                ;;
            -x)
                set -x
                ;;
            -mcp)
                EN_MCP="1"
                ;;
            *)
                script_usage
                ;;
        esac
    done
}

kill_screen_sessions() {
  # Kills screen *processes* for the current user.
  # -x ensures exact match on process name (safer than substring matching).
  pkill -u "$USER" -x screen 2>/dev/null || true
}

cleanup() {
  kill_screen_sessions
}



# DESC: Main control flow
# ARGS: $@ (optional): Arguments provided to the script
# OUTS: None
# RETS: None
function main() {
    script_init "$@"
    parse_params "$@"

    trap cleanup INT TERM EXIT
    project_dir="${script_dir}/.."
    agent_file="${script_dir}/agents/kicad_helper.md"

    if [ "${EN_MCP}" -eq "1" ]; then
        screen -dmS kimcp uv --project tools/kimcp/ run tools/kimcp/run.py
    fi

    # TODO setup trap to kill screen

    docker run -it --rm \
        --network host \
        -v ${project_dir}:/workspace/${project_name} \
        -v ${agent_file}:/workspace/AGENTS.md \
        codex:latest \
        /codex

    cleanup
}

# Invoke main with args if not sourced
# Approach via: https://stackoverflow.com/a/28776166/8787985
if ! (return 0 2> /dev/null); then
    main "$@"
fi

# vim: syntax=sh cc=80 tw=79 ts=4 sw=4 sts=4 et sr
