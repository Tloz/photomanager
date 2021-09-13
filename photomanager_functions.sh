#! /bin/bash

# photomanager_functions.sh
# Copyright (C) Emeric Fremion <scrimet@hotmail.fr>
# Licenced under the terms of the LGLP
# Created on 2020 May 9


function version()
{
    SEMVER=$SEMVER_X.$SEMVER_Y
    if [ ! -z $SEMVER_Z ]; then
        SEMVER+=".$SEMVER_Z"
    fi
    if [ ! -z $SEMVER_A ]; then
        SEMVER+="-$SEMVER_A"
    fi
    echo -n "$(basename $0) version $SEMVER"
    echo ""
}

function usage()
{
    echo "Use : $(basename "$0") [OPTIONS]... FOLDER"
    echo "rename files in FOLDER accordingly to metadata or filename structure."
    echo "  -m          use metadata to rename files (default)"
    echo "  -n          use filename format to rename files (experimental)"
    echo "  -b          use both methods to rename (metadata THEN filename)"
    echo "  -t          do not rename, just pretend"
    echo ""
    echo "  -s          write to stdout (default)"
    echo "  -l          write to log file ($MAIN_LOG)"
    echo "  -q          quiet"
    echo ""
    echo "  -o [FOLDER] move renamed files into FOLDER"
    echo "  -c          clean, moves file to corresponding year folder"
    echo ""
    echo "  -d          show debug messages"
    echo "  -h          show this message"
    echo ""
    echo "Licenced under the terms of the LGLP"
    echo ""
}


function debug()
{
    if [ "$DEBUG" = "yes" ]; then
        echo "DEBUG : $1"
    fi
}

function say()
{
    if [ "$VERBOSITY" = "s" ]; then
        echo "$1"
    elif [ "$VERBOSITY" = "l" ]; then
        echo "$1" >> "$MAIN_LOG"
    fi
}

function lowercaseName()
{
    echo "$1" | tr '[:upper:]' '[:lower:]'
    echo -n ""
}

function ensureFolderExists()
{
    if [ -z "$1" ]; then
        say "Error : function ensureFolderExists must have one argument. Aborting"
        return 255
    else
        if [ ! -d "$1" ]; then
            say "Create folder $1"
            mkdir "$1/"
        fi
    fi
}

function getFileName()
{
    if [ -z "$1" ]; then
        return 255
    else
        filename=$(basename -- "$1")
        echo "$filename"
    fi
}

function getBaseName()
{
    if [ -z "$1" ]; then
        return 255
    else
        basename=$(basename -- "$1" | cut -d'.' -f1)
        echo "$basename"
    fi
}

function getFileExtension()
{
    if [ -z "$1" ]; then
        return 255
    else
        echo "$1" | sed 's/.*\.//g'
    fi
}

function getDateTimeTag()
{
    TAG=$(file "$1" | grep datetime)
    if [ -z "$TAG" ]; then
        return 255
    fi
    TAG=$(echo "$TAG" | sed 's/^.*datetime=//' | cut -d',' -f1 | cut -d']' -f1)
    echo "$TAG"
}

function makeNameFromTag()
{
    if [ $# -ne 1 ]; then
        return 255
    fi
    TAG="$1"
    YYYY=$(echo "$TAG" | cut -d':' -f1)
    MM=$(echo "$TAG" | cut -d':' -f2)
    DD=$(echo "$TAG" | cut -d':' -f3 | cut -f1 -d' ')
    HH=$(echo "$TAG" | cut -d':' -f3 | cut -f2 -d' ')
    mm=$(echo "$TAG" | cut -d':' -f4)
    SS=$(echo "$TAG" | cut -d':' -f5)
    newname="$YYYY-$MM-$DD $HH$mm$SS.$EXT"

    echo "$newname"
}

function makeNameFromFile()
{
    if [ $# -ne 1 ]; then
        return 255
    fi
    string="$1"
    string=$(echo "$string" | sed -E -e "s/^$REGEX_FINAL\$/\2-\3-\4 \6\8/")
    echo "$string"
}

function makeUniqueFilename()
{
    if [ $# -ne 1 ]; then
        return 255
    fi
    tmp_name="$1"
    if [ ! -f "$OUT_FOLDER/$tmp_name" ]; then
        echo "$tmp_name"
        return 0
    else
        IDX=1
        baseName=$(echo "$tmp_name" | cut -d'.' -f1)
        EXT=$(getFileExtension "$tmp_name")

        comparison_name="$baseName"
        comparison_name+="_"
        comparison_name+="$IDX"
        comparison_name+="."
        comparison_name+="$EXT"

        while [ -f "$OUT_FOLDER/$comparison_name" ]; do
            IDX=$(($IDX + 1))
            comparison_name="$baseName"
            comparison_name+="_"
            comparison_name+="$IDX"
            comparison_name+="."
            comparison_name+="$EXT"
        done

        echo "$comparison_name"
    fi
}

function RoutineRenameMeta()
{
    file="$1"
    # extracting extension
    EXT=$(getFileExtension "$file")
    if [ $? -eq 255 ]; then
        say "Error - function getFileExtension must have an argument. Aborting"
        return 127
    fi

    # extracting TAG
    TAG=$(getDateTimeTag "$file")
    if [ $? -eq 255 ]; then
        say "Error - No date TAG found for $1, exiting"
        FAILED=$((FAILED + 1))
        return 127
    fi

    # building new name
    newName=$(lowercaseName "$(newNameFromTag "$TAG")")
    if [ $? -eq 255 ]; then
        say "Error - function newNameFromTag and lowercaseName must have an argument. Aborting"
        return 127
    fi

    # checking newName unicity, building an other new name if necessary
    modName=$(makeUniqueFilename "$newName")
    if [ $? -eq 255 ]; then
        say "Error - function makeUniqueFilename must have an argument. Aborting"
        return 127
    fi

    if [ "$TEST" = "yes" ]; then
        say "moving $file to $OUT_FOLDER/$modName"
        return 1
    fi

    # finally moving the file
    if mv -n "$1" "$OUT_FOLDER/$modName"; then
        say "moving $file to $OUT_FOLDER/$modName"
        TOUCHED=$((TOUCHED + 1))
    else
        say "$file hasn't been renamed. Please investigate"
        return 127
    fi
}

function RoutineRenameFile()
{
    file="$1"

    # is filename matching the regex?
    if [[ "$file"  =~ $REGEX_FINAL ]]; then
        # renaming with the regex
        newName=$(makeNameFromFile "$file")
    else
        say "Error - can't rename $file. Filename structure doesn't match"
        return 128
    fi

    # building new name
    newName=$(lowercaseName "$newName")
    if [ $? -eq 255 ]; then
        say "Error - function newNameFromTag and lowercaseName must have an argument. Aborting"
        return 127
    fi

    # checking newName unicity, building an other new name if necessary
    modName=$(makeUniqueFilename "$newName")
    if [ $? -eq 255 ]; then
        say "Error - function makeUniqueFilename must have an argument. Aborting"
        return 127
    fi

    if [ "$TEST" = "yes" ]; then
        say "moving $file to $OUT_FOLDER/$modName"
        return 1
    fi

    # finally moving the file
    if mv -n "$1" "$OUT_FOLDER/$modName"; then
        say "moving $file to $OUT_FOLDER/$modName"
        TOUCHED=$((TOUCHED + 1))
    else
        say "$file hasn't been renamed. Please investigate"
        return 127
    fi
}

function checkProperRename()
{
    filename="$1"
    if [[ ! $filename =~ $REGEX_TARGET ]]; then
        echo "Filename $filename not compliant with regexp. Aborting."
        return 255
    fi
    echo "Filename is properly formed !"
    return 0
}

function moveToYearFolder()
{
    filename=$1
    if [[ ! $filename =~ $REGEX_TARGET ]]; then
        echo "Filename $filename not compliant with regexp. Aborting."
        return 255
    fi

    YEAR=$(echo "$filename" | cut -c1-4)

    # on vérifie l'existence du dossier de destination, sinon on le crée
    if [ ! -d "$YEAR" ]; then
        say "Creating $YEAR folder"
        mkdir "$YEAR"
    fi

    # on vérifie qu'un fichier du même nom n'existe pas déjà
    modName=$(makeUniqueFilename "$1")
    if [ $? -eq 255 ]; then
        return 127
    fi

    if mv -n "$filename" "$YEAR/$modName"; then
        echo "moving $filename to $YEAR/$modName"
        MOVED=$((MOVED + 1))
    else
        say "$filename hasn't been renamed. Please investigate"
        return 125
    fi
}