#!/bin/bash

function help {
echo "
Title: This script is used to convert [TOC] to an anchored table of contents for Gitlab/Github

How to use in terminal:
./toc_to_md.sh file.md

Optional arguments:
    -h, --help - show this help message
    -v, --version - show this version
    --author - show author of this script
"
}

function version {
echo "
Version: 3.4.1
"
}

function author {
echo "
author: OlegKocha (https://github.com/OlegKocha)
"
}

if [[ $1 == "-h" ]]; then
    help
    exit
elif [[ $1 == "--help" ]]; then
    help
    exit
fi

if [[ $1 == "-v" ]]; then
    version
    exit
elif [[ $1 == "--version" ]]; then
    version
    exit
fi

if [[ $1 == "--author" ]]; then
    author
    exit
fi


# find name of file
file=$1

# Temp file name
temp_file='.tempfile.txt'

# New file name with new table for Github/GitLab
new_table='new_table_'$file


# Check correct file
if [ ${file: -3} == ".md" ]
then
    echo 'file name:' $file
else
    echo 'Its not a MarkDown file or unspecified file'
    exit
fi


echo "# Содержание:" > $new_table

cat $file | grep "#" > $temp_file # find all line with "#"

readarray tablearray < $temp_file # table in array

echo -n > $temp_file # clear temp file

for table in "${tablearray[@]}"
do
    quantity=$(echo $table | tr -cd "#" | wc -m) # calculate all '#' in file md
    first_symbol=$(echo $table | head -c 1)
    if [[ $quantity -ne 10 ]] ;then # if in $table more 10 "#" symbols -> skip
        #echo $table
        if [[ $first_symbol == "#" ]]; then
            echo $table >> $temp_file
        fi
    fi
done

readarray tablearray < $temp_file # now its tru table in array

find_toc=$(cat $file| grep TOC)

if [ ! -z "$find_toc" ]; then
    cat $file | sed -e "s/\[TOC\]//g" > $temp_file # del [TOC]
else
    find_toc=$(cat $file| grep toc)
    if [ ! -z "$find_toc" ]; then
        cat $file | sed -e "s/\[toc\]//g"  > $temp_file # del [toc]
    else
        echo "NO TOC"
        exit
    fi
fi

# Counters
COUNTER_introduction=0
COUNTER_paragraph=0      
COUNTER_subparagraph=0
COUNTER_subsubparagraph=0
COUNTER_subsubsubparagraph=0
COUNTER_subsubsubsubparagraph=0
COUNTER_subsubsubsubsubparagraph=0
COUNTER_subsubsubsubsubsubparagraph=0
COUNTER_subsubsubsubsubsubsubparagraph=0
COUNTER_subsubsubsubsubsubsubsubparagraph=0

for table in "${tablearray[@]}"
do
    quantity=$(echo $table | tr -cd "#" | wc -m) # calculate all '#' in file md
    table_without_symbol=$(echo $table | tr -d "#" | sed -e 's/^ *//g')
    quantity_tabs=$(echo "scale=3; 4 * $quantity - 4" | bc) # formula 4 * x - 4 = y, where 'x' its quantity all # in md, y - quantity spaces we need in new file
    tabs=$(printf %"$quantity_tabs"s)
    if [ $quantity == 1 ] ;then
        link_name="#introduction"$COUNTER_introduction
        COUNTER_introduction=$[COUNTER_introduction + 1]
    elif [ $quantity == 2 ]; then
        link_name="#paragraph"$COUNTER_paragraph
        COUNTER_paragraph=$[COUNTER_paragraph + 1]
    elif [ $quantity == 3 ]; then
        link_name="#subparagraph"$COUNTER_subparagraph
        COUNTER_subparagraph=$[COUNTER_subparagraph + 1]
    elif [ $quantity == 4 ]; then
        link_name="#subsubparagraph"$COUNTER_subsubparagraph
        COUNTER_subsubparagraph=$[COUNTER_subsubparagraph + 1]
    elif [ $quantity == 5 ]; then
        link_name="#subsubsubparagraph"$COUNTER_subsubsubparagraph
        COUNTER_subsubsubparagraph=$[COUNTER_subsubsubparagraph + 1]
    elif [ $quantity == 6 ]; then
        link_name="#subsubsubsubparagraph"$COUNTER_subsubsubsubparagraph
        COUNTER_subsubsubsubparagraph=$[COUNTER_subsubsubsubparagraph + 1]
    elif [ $quantity == 7 ]; then
        link_name="#subsubsubsubsubparagraph"$COUNTER_subsubsubsubsubparagraph
        COUNTER_subsubsubsubsubparagraph=$[COUNTER_subsubsubsubsubparagraph + 1]
    elif [ $quantity == 8 ]; then
        link_name="#subsubsubsubsubsubparagraph"$COUNTER_subsubsubsubsubsubparagraph
        COUNTER_subsubsubsubsubsubparagraph=$[COUNTER_subsubsubsubsubsubparagraph + 1]
    elif [ $quantity == 9 ]; then
        link_name="#subsubsubsubsubsubsubparagraph"$COUNTER_subsubsubsubsubsubsubparagraph
        COUNTER_subsubsubsubsubsubsubparagraph=$[COUNTER_subsubsubsubsubsubsubparagraph + 1]
    elif [ $quantity == 10 ]; then
        link_name="#subsubsubsubsubsubsubsubparagraph"$COUNTER_subsubsubsubsubsubsubsubparagraph
        COUNTER_subsubsubsubsubsubsubsubparagraph=$[COUNTER_subsubsubsubsubsubsubsubparagraph + 1]
    fi  
    echo -e "$tabs""- [**"$table_without_symbol"**]("$link_name")" >> $new_table
done


readarray tablearray < $new_table


for table in "${tablearray[@]}"
do
    #echo "$table"
    name=$(echo $table | grep -Po '(?<=\[\*\*).*(?=\*\*\])')
    link_name=$(echo $table | grep -Po '(?<=\#).*(?=\))')
    replace="<a name=\"$link_name\"></a>"
    need_replace=$(echo $name $replace)
    if [ ! -z "$name" ]; then
        python3 replace.py "$temp_file" "$name" "$need_replace"
    fi
  
done


cat $temp_file >> $new_table # add all new intformation in new file

rm $temp_file # del temp file

echo New table: $new_table
exit
