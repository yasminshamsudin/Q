#!/bin/bash

# By Yasmin 2009

# This script changes the name of the mol2-files from the GOLD Docking session

 date=$( date +%y%m%d)
 dockingprogram=PLP
 mkdir $date.$dockingprogram
 mkdir $date.$dockingprogram/ORIGINALS

 for i in *.mol2
 do
 oldname=$( echo "$i" | sed -e 's/\.mol2//g')
 nameinfile=$( sed -ne "/MOLECULE/{n;p;}" $oldname.mol2)
 newnameinfile=$( echo $nameinfile | sed "s/|.*dock/d/g") #removes junk in name
 noblanks=$( echo $newnameinfile | sed 's/\s//' | sed 's/\.//' ) #removes blanks
 short=${noblanks:0:10}

 cp $oldname.mol2 $short.mol2

 mv $oldname.mol2 $date.$dockingprogram/ORIGINALS/
 wait
 done

# Done :)
