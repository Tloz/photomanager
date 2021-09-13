#! /bin/bash

# photomanager_settings.sh
# Copyright (C) Emeric Fremion <scrimet@hotmail.fr>
# Licenced under the terms of the LGLP
# Created on 2020 May 9

########### SETTINGS ###########
SEMVER_X="1"
SEMVER_Y="0"
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
# What format can you work on?
SUPPORTED_FORMATS="jpg jpeg png avi mp4 3gp"
# SUPPORTED_FORMATS="jpg JPG jpeg JPEG png PNG avi AVI mp4 MP4 3gp 3GP"

# Regex
REGEX_PRE="[A-Za-z -_]*"      #1 ou plusieurs char et éventuellement un séparateur, le tout facultatif
REGEX_YEAR="[0-9]{4}"         #4 chiffres
REGEX_MONTH="[0-9]{2}"        #2 chiffres
REGEX_DAY="[0-9]{2}"          #2 chiffres
REGEX_SEP="[A-Za-z -_]*"      #1 éventuellement séparateur avec des notes facultatives
REGEX_TCODE="[0-9]{4,6}?"     #1 timecode facultatif de 4 à 6 chiffres
REGEX_NOTE="[A-Za-z -_]*"     #1 blabla
REGEX_EXT="\.[[:alnum:]]{3,4}"

REGEX_FINAL="^($REGEX_PRE)($REGEX_YEAR)($REGEX_MONTH)($REGEX_DAY)($REGEX_SEP)($REGEX_TCODE)($REGEX_NOTE)($REGEX_EXT)\$"
REGEX_TARGET="^[0-9]{4}-[0-9]{2}-[0-9]{2}( [0-9]{4,6})?$REGEX_EXT"
################################

########## ARGUMENTS ###########
ARGUMENT_STRING="mnbtslqo:cdvh"
TODO="m"
TEST="no"
TOUCHED=0
FAILED=0
MOVED=0
################################