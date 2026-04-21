#!/usr/bin/env bash
#
# +----------------------------------------------------------------------------+
# | ./fancy-motd/framework.sh                                                  |
# +----------------------------------------------------------------------------+
# |       Usage: ---                                                           |
# | Description: Framework for Fancy MOTD                                      |
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

                                                                                # Provide default values for obligatory settings
                                                                                # Colors
CA="\e[34m"                                                                     # Accent
CO="\e[32m"                                                                     # Ok
CW="\e[33m"                                                                     # Warning
CE="\e[31m"                                                                     # Error
CN="\e[0m"                                                                      # None

WIDTH="${WIDTH:-50}"                                                            # Max width used for components in second column

source "$CONFIG_PATH"                                                           # Source the config file


get_os () {                                                                     # Get some OS information
    read -r os kernel arch <<-EOF
        $(uname -srm)
EOF
    [[ -f "/etc/os-release" ]] && source /etc/os-release
    export PRETTY_NAME os kernel arch

    PRETTY_NAME="${PRETTY_NAME:="Unkown"}"                                      # Are we all set?
    os="${os:="Unkown"}"
    kernel="${kernel:="Unkown"}"
    arch="${arch:="Unkown"}"
}

print_columns() {                                                               # Prints given blocks of text side by side
    [ -z "$2" ] && return                                                       # $1 - left column
    paste <(echo -e "${CA}$1${1:+:}${CN}") <(echo -e "$2")                      # $2 - right column
}

print_n() {                                                                     # Prints given text n times
    local out=""                                                                # $1 - text to print
    for ((i=0; i<$2; i++)); do                                                  # $2 - how many times to print
        out+="$1"
    done
    echo "$out"
}

print_bar() {                                                                   # Prints bar divided in two parts by given percentage
    local bar_width=$(($1 - 2))                                                 # $1 - bar width
    local used_width=$(($2 * $bar_width / 100))                                 # $2 - percentage
    local free_width=$(($bar_width - $used_width))
    local out=""
    out+="["
    out+="${CE}"
    # out+=$(print_n "=" $used_width)
    out+=$( print_n ${BARCHARUSED} ${used_width} )
    out+="${CO}"
    # out+=$(print_n "=" $free_width)
    out+=$( print_n ${BARCHARFREE} ${free_width} )
    out+="${CN}"
    out+="]"
    echo "$out"
}

print_color() {                                                                 # Prints text with color according to given value and two thresholds
    local out=""                                                                # $1 - text to print
    if (( $("$bc" -l <<< "$2 < $3") )); then                                    # $2 - current value
        out+="${CO}"                                                            # $3 - warning threshold
    elif (( $("$bc" -l <<< "$2 >= $3 && $2 < $4") )); then                      # $4 - error threshold
        out+="${CW}"
    else
        out+="${CE}"
    fi
    out+="$1${CN}"
    echo "$out"
}

print_status() {                                                                # Prints text as either acitve or inactive
    local out=""                                                                # $1 - text to print
    if [ "$2" == "active" ]; then                                               # $2 - literal "active" or "inactive"
        # out+="${CO}▲${CN}"
        out+="${CO}${SIGCHARUP}${CN}"
    else
        # out+="${CE}▼${CN}"
        out+="${CE}${SIGCHARDO}${CN}"
    fi
    out+=" $1${CN}"
    echo "$out"
}

print_wrap() {                                                                  # Prints comma-separated arguments wrapped to the given width
    local width=$1                                                              # $1 - width to wrap to
    shift                                                                       # $2, $3, ... - values to print
    local out=""
    local line_length=0
    for element in "$@"; do
        element="$element,"
        local visible_elelement="$(strip_ansi "$element")"
        local future_length=$(($line_length + ${#visible_elelement}))
        if [ $line_length -ne 0 ] && [ $future_length -gt $width ]; then
            out+="\n"
            line_length=0
        fi
        out+="$element "
        line_length=$(($line_length + ${#visible_elelement}))
    done
    [ -n "$out" ] && echo "${out::-2}"
}

print_split() {                                                                 # Prints some text justified to left and some justified to right
    local visible_first visible_second invisible_first_width \
        invisible_second_width total_width \
        first_half_width second_half_width format_string

    visible_first="$(strip_ansi "$2")"                                          # $1 - total width
    visible_second="$(strip_ansi "$3")"                                         # $2 - left text
    invisible_first_width=$((${#2} - ${#visible_first}))                        # $3 - right text
    invisible_second_width=$((${#3} - ${#visible_second}))
    total_width=$(($1 + invisible_first_width + invisible_second_width))

    if (( ${#visible_first} + ${#visible_second} < $1 )); then
        first_half_width=${#2}
    else
        first_half_width=$(($1 / 2))
    fi
    second_half_width=$((total_width - first_half_width))

    format_string="%-${first_half_width}s%${second_half_width}s"
    printf $format_string "${2:0:$first_half_width}" "${3:0:$second_half_width}"
}

print_truncate() {                                                              # Prints one line of text, truncates it at specified width and add ellipsis.
    local out                                                                   # Truncation can occur either at the start or at the end of the string.
    local new_length=$(($2 - 1))                                                # $1 - line to print
    # Just echo the string if it's shorter than the limit                       # $2 - width limit
    if [ ${#1} -le $2 ]; then                                                   # $3 - "start" or "end", default "end"
        out="$1"
    elif [ -z "$3" ] || [ "$3" = "end" ]; then
        out="${1::$new_length}…"
    else
        out="…${1: -$new_length}"
    fi
    echo "$out"
}

strip_ansi() {                                                                          # Strips ANSI color codes from given string
    echo "$(echo -e "$1" | "$sed" -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g")"    # $1 - text to strip
}

columnize() {                                                                   # Following is basically simple `column` reimplementation because it doesn't work consistently.
                                                                                # I fucked way too long with this.
                                                                                # $1 - text to columnize
                                                                                # $2 - column separator
                                                                                # $3 - row separator
    local left_lines left_widths right_lines max_left_width left right visible_left \
        padding_width padding
    left_lines=()                                                               # Lines in left column
    left_widths=()                                                              # Numbers of visible chars in left lines
    right_lines=()                                                              # Lines in right column
    max_left_width=0                                                            # Max width of left column line
    while IFS="$3" read -r line; do                                             # Iterate over lines and populate above variables
        left="$(echo -e "$line" | cut -d "$2" -f 1)"
        right="$(echo -e "$line" | cut -d "$2" -f 2)"
        left_lines+=("$left")
        right_lines+=("$right")
        visible_left="$(strip_ansi "$left")"
        left_widths+=(${#visible_left})
        [ ${#visible_left} -gt $max_left_width ] && max_left_width=${#visible_left}
    done <<< "$1"
    for ((i=0; i<${#left_lines[@]}-1; i++)); do                                 # Iterate over lines and print them while padding left column with spaces
        padding_width=$((max_left_width - left_widths[$i]))
        padding="$(print_n " " $padding_width)"
        echo -e "${left_lines[$i]}${padding}  ${right_lines[$i]}"
    done
}
# +----- End ------------------------------------------------------------------+
