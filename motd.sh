#!/usr/bin/env bash

# Don't change! We want predictable outputs
export LANG="en_US.UTF-8"

# Dir of this script
export BASE_DIR="$(dirname "$(readlink -f "$0")")"

# Set config path
if [ -z ${1+x} ]; then
    export CONFIG_PATH="$BASE_DIR/config.sh"
    if [ ! -f "$CONFIG_PATH" ] && [ -f "$BASE_DIR/config.sh.example" ]; then
        cp $BASE_DIR/config.sh.example $CONFIG_PATH
    fi
else
    export CONFIG_PATH="$1"
fi

# Check for config path
if [ ! -f "$CONFIG_PATH" ]; then
    echo "Error: No config file found."
    echo "       You may provide one like this: $0 /your/path/config.sh"
    exit 1
fi

# Source the framework
source "$BASE_DIR/framework.sh"

# Get OS information here instead of calling uname several times.
get_os

# Get our goods together
case $os in 
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

# Run the modules and collect output
output=""
modules="$(ls -1 "$BASE_DIR/modules" | perl -nle 'print if m{^(?<!\d)\d{2}(?!\d)-}')"
while read -r module; do
    # module_output="$($BASE_DIR/modules/$module 2>/dev/null)"
    module_output="$($BASE_DIR/modules/$module)"
    [ $? -ne 0 ] && continue
    output+="$module_output"
    [ -n "$module_output" ] && output+=$'\n'
done <<< "$modules"

# Print the output in pretty columns
columnize "$output" $'\t' $'\n'
