#!/usr/bin/env bash
#
# +----------------------------------------------------------------------------+
# | ./fancy-motd/motd.sh                                                       |
# +----------------------------------------------------------------------------+
# |       Usage: ---                                                           |
# | Description: Fancy Message Of The Day                                      |
# |    Requires: Fancy MOTD                                                    |
# |       Notes: ---                                                           |
# |      Author: Waldemar Schroeer                                             |
# |     Company: Rechenzentrum Amper                                           |
# |     Version: 1.1                                                           |
# |     Created: 2021-03-31                                                    |
# |    Revision: 2026-04-21                                                    |
# |                                                                            |
# | Copyright © 2022 Waldemar Schroeer                                         |
# |                  waldemar.schroeer(at)rz-amper.de                          |
# +----------------------------------------------------------------------------+

export LANG="en_US.UTF-8"                                                       # Set the locale to UTF-8
export BASE_DIR="$(dirname "$(readlink -f "$0")")"                              # Dir of this script

if [ -z ${1+x} ]; then                                                          # Set config path
    export CONFIG_PATH="$BASE_DIR/config.sh"
    if [ ! -f "$CONFIG_PATH" ] && [ -f "$BASE_DIR/config.sh.example" ]; then
        cp $BASE_DIR/config.sh.example $CONFIG_PATH
    fi
else
    export CONFIG_PATH="$1"
fi

if [ ! -f "$CONFIG_PATH" ]; then                                                # Check for config path
    echo "Error: No config file found."
    echo "       You may provide one like this: $0 /your/path/config.sh"
    exit 1
fi

source "$BASE_DIR/framework.sh"                                                 # Source the framework
get_os                                                                          # Get OS information here instead of calling uname several times.
case $os in                                                                     # Get our goods together
    Linux*)
    export awk="awk"
    export sed="sed"
    export bc="bc"
    ;;

    FreeBSD)
    export awk="awk"
    export sed="sed"
    export bc="bc"
    ;;

    SunOS)
    export awk="gawk"
    export sed="gsed"
    export bc="gbc"
    ;;
esac

output=""                                                                       # Run the modules and collect output
modules="$(ls -1 "$BASE_DIR/modules" | perl -nle 'print if m{^(?<!\d)\d{2}(?!\d)-}')"
while read -r module; do
    # module_output="$($BASE_DIR/modules/$module 2>/dev/null)"
    module_output="$($BASE_DIR/modules/$module)"
    [ $? -ne 0 ] && continue
    output+="$module_output"
    [ -n "$module_output" ] && output+=$'\n'
done <<< "$modules"

columnize "$output" $'\t' $'\n'                                                 # Print the output in pretty columns
# +----- End ------------------------------------------------------------------+
