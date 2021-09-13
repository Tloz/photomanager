#! /bin/bash

# photomanager_settings.sh
# Copyright (C) Emeric Fremion <scrimet@hotmail.fr>
# Licenced under the terms of the LGLP
# Created on 2020 May 9

########### SETTINGS ###########
SEMVER_X="1"
SEMVER_Y="1"
SEMVER_Z=""
SEMVER_A=""
# Folders
OUT_FOLDER="."
# Verbose ?
DEBUG="no"
VERBOSITY="s" # s(tdout) | l(og) | q(uiet)
# log
MAIN_LOG="photomanager.log"
CLEAN="no"
CHECK="no"

# Regex
REGEX_SEP="[A-Za-z -_]*"
REGEX_YEAR="[0-9]{4}"
REGEX_MONTH="[0-9]{2}"
REGEX_DAY="[0-9]{2}"
REGEX_DATE="($REGEX_YEAR)($REGEX_MONTH)($REGEX_DAY)"
REGEX_TCODE="[0-9]{4,6}?"
REGEX_NOTE="[A-Za-z -_]*"
REGEX_EXT="\.[[:alnum:]]{3,4}"

REGEX_FINAL="^($REGEX_SEP)$REGEX_DATE($REGEX_SEP)($REGEX_TCODE)($REGEX_NOTE)($REGEX_EXT)\$"
REGEX_TARGET="^[0-9]{4}-[0-9]{2}-[0-9]{2}( [0-9]{4,6}(_[0-9]+)?)?$REGEX_EXT\$"
################################

########## ARGUMENTS ###########
ARGUMENT_STRING="slqo:fctdvh"
TEST="no"
TOUCHED=0
MOVED=0
################################
