#!/usr/bin/env bash

#======== General Config ======================================================
# Colors
# CA="\e[34m"									# Accent
# CO="\e[32m"									# Ok
# CW="\e[33m"									# Warning
# CE="\e[31m"									# Error
# CN="\e[0m"									# None

# BARCHARUSED="#"
# BARCHARFREE="-"

BARCHARUSED=""
BARCHARFREE=""

CA=""									# Accent
CO=""									# Ok
CW=""									# Warning
CE=""									# Error
CN=""									# None

# Max width used for components in second column
WIDTH=63

#======== MODULES =============================================================

# ATEST
MOD_ATEST_RUN="false"

# DATETIME
MOD_DATETIME_RUN="true"

# BANNER
MOD_BANNER_RUN="false"
MOD_BANNER_PRINT="HOSTNAME"
MOD_BANNER_FONT="smslant.flf"

# USER
MOD_USER_RUN="false"
MOD_USER_LAST="true"

# OS
MOD_OS_RUN="false"
MOD_OS_VERBOSE="true"

# IP
MOD_IP_RUN="false"

# PUBLIC-IP
MOD_PUBLIC_IP_RUN="false"

# UPTIME
MOD_UPTIME_RUN="true"

# LOAD
MOD_LOAD_RUN="true"

# MEMORY
MOD_MEMORY_RUN="true"
MOD_MEMORY_FREEBSD_VERBOSE="true"

# DISK
MOD_DISK_RUN="true"

# SERVICES
MOD_SERVICES_RUN="false"
# List of services to check
declare -A services
services["nginx"]="nginx"
services["Docker"]="docker"
services["SSH"]="sshd"
services["Fail2Ban"]="fail2ban"
services["UFW"]="ufw"

# CERTIFICATE VALIDITY
MOD_CERT_RUN="false"
# Short Name; FQDN; TCP Port
declare -A certhostlist
certhostlist[1]="FreeBSD WWW;www.freebsd.org;443"
certhostlist[2]="Google WWW;www.google.de;443"
certhostlist[3]="Google IMAP;imap.google.de;993"
certhostlist[4]="Google SMTP;smtp.gmail.de;465"

# TMUX
MOD_TMUX_RUN="false"

# UPDATES
MOD_UPDATES_RUN="false"

# QUOTE
MOD_QUOTE_RUN="fales"

# WEATHER
MOD_WEATHER_RUN="true"
MOD_WEATHER_LOCATION="Fuerstenfeldbruck"
# MOD_WEATHER_OPTIONS=(format="%c+%t+(%f)+%h+%w+%P+%m")
# MOD_WEATHER_OPTIONS=(0Q)
MOD_WEATHER_OPTIONS=(FQTn1)
