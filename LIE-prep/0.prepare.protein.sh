#!/bin/bash 

# By Yasmin 2012-01-09
 
# This script prepares the protein from the original pdb to a Q-readable pdb.

# date=120605
 date=$( date +%y%m%d)
 inputfilename=hCOX-2.preQ
 Qproteinname=Q.hCOX2.new

 mkdir $inputfilename-preparation

 for i in $inputfilename.pdb
 do

 radius=90.0            # Set Radius

# x=25.98 y=33.163 z=202.843		# Set x, y, z coordinates
 x=26.387 y=34.363 z=201.281

# Create maketop-files
# Please NOTE addition of heme.lib!

 echo -e rl ../Qoplsaa.lib'\n'rl ../heme.lib'\n'rff ../Qoplsaa.prm'\n'rp ../$inputfilename.pdb'\n'boundary sphere $x $y $z $radius'\n'mt $inputfilename $radius'\n'wt $Qproteinname.top'\n'wp $Qproteinname.pdb y'\n'quit > $inputfilename-preparation/$inputfilename.maketop.inp

cd $inputfilename-preparation/

# Run Qprep5

 Qprep5 < $inputfilename.maketop.inp > $inputfilename.top.log
 wait

done
# DONE :)

