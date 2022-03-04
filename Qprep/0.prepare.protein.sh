#!/bin/bash 

# By Yasmin 2012-01-09
# 2022-02-17 Re-structured 

# This script prepares the protein from the original pdb to a Q-readable pdb.

 inputfile=Q.TEM1
 Qprotein=Q.TEM1.new

 x=4.641 y=8.878 z=22.866 # Set x, y, z coordinates
 radius=90.0            # Set Radius (Make it larger than the whole protein)

############ No More Editing! #######

 mkdir $inputfile-prep

 for i in $inputfile.pdb
 do

# Create maketop-files

 echo -e 'rl ../PARAMETERS/Qoplsaa.lib' > $inputfile-prep/$inputfile.maketop.inp
 echo -e 'rff ../PARAMETERS/Qoplsaa.prm' >> $inputfile-prep/$inputfile.maketop.inp
 echo -e "rp ../$inputfile.pdb" >> $inputfile-prep/$inputfile.maketop.inp
 echo -e "boundary sphere $x $y $z $radius" >> $inputfile-prep/$inputfile.maketop.inp
 echo -e "mt $inputfile $radius" >> $inputfile-prep/$inputfile.maketop.inp
 echo -e "wt $Qprotein.top" >> $inputfile-prep/$inputfile.maketop.inp
 echo -e "wp $Qprotein.pdb y" >> $inputfile-prep/$inputfile.maketop.inp
 echo -e 'quit' >> $inputfile-prep/$inputfile.maketop.inp 

cd $inputfile-prep/

# Run Qprep5

 qprep5 < $inputfile.maketop.inp > $inputfile.top.log
 wait

done
# DONE :)

