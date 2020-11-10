#!/bin/bash

# By Yasmin 2009

# This script removes extra numbers added to the filename from Maestro

 for i in *.mae
 do
 
 oldname=$( echo "$i" | sed -e 's/\.mae//g')
 filename=$( echo  $oldname | sed -e 's/\.[0-9]*//g')
 mv $oldname.mae $filename.mae

 wait
 done

# Done :)
