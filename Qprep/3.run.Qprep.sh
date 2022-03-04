#!/bin/bash 

# By Yasmin 2009 altered 2010-03-02
# 2022-02-18 Edited to fit new formating (Q.lib & Q.parm)
 
# This script creates: 
# - maketop-files for ligands in water and protein 
# - the respective dcd-files
# Finally it runs Qprep5 for all systems and cleans the directory.

# date=140212i
 date=$( date +%y%m%d)
 protein=Q.TEM1     # Give protein name
 radius=30.0        # Set radius of sphere
 boundary=30.3      # Set water boundary (0.3 beyond simulation sphere)

# Set x, y, z coordinates
 x=4.641  
 y=8.878  
 z=22.866	

########################### No MORE CHANGES AFTER THIS POINT!!! ##################

for i in *.mae
 do
 ligname=$( echo "$i" | sed -e 's/\.mae//g')

  mkdir $date.prep
  mkdir $date.$protein
# Create maketop-files

 echo -e rl PARAMETERS/Qoplsaa.lib'\n'rl Q.$ligname.lib'\n'rff Q.$ligname.prm'\n'rp Q.$ligname.pdb'\n'boundary sphere $x $y $z $radius'\n'solvate boundary $boundary 1 HOH'\n'mt $ligname $protein $radius A'\n'wt $ligname.water.top'\n'wp $ligname.water.top.pdb y'\n'quit > $ligname.water.maketop.inp

 echo -e rff $ligname.prm'\n'rt $ligname.water.top'\n'boundary sphere $x $y $z $radius'\n'ma none'\n'ma not excluded'\n'mt $ligname $protein $radius A'\n'wp $ligname.water.dcd_top.pdb y'\n'quit > $ligname.make.water.dcd.top.inp

 echo -e rl PARAMETERS/Qoplsaa.lib'\n'rl Q.$ligname.lib'\n'rff Q.$ligname.prm'\n'rp Q.$ligname.complex.pdb'\n'boundary sphere $x $y $z $radius'\n'solvate boundary $boundary 1 HOH'\n'mt $ligname $protein $radius A'\n'wt $ligname.protein.top'\n'wp $ligname.protein.top.pdb y'\n'quit > $ligname.protein.maketop.inp

 echo -e rff $ligname.prm'\n'rt $ligname.protein.top'\n'boundary sphere $x $y $z $radius'\n'ma none'\n'ma not excluded'\n'mt $ligname $protein $radius A'\n'wp $ligname.protein.dcd_top.pdb y'\n'quit > $ligname.make.protein.dcd.top.inp

# Run Qprep5

 qprep5 < $ligname.water.maketop.inp > $ligname.water.top.log
 wait
 qprep5 < $ligname.make.water.dcd.top.inp > $ligname.make.water.dcd.top.log
 wait
 qprep5 < $ligname.protein.maketop.inp > $ligname.protein.top.log
 wait
 qprep5 < $ligname.make.protein.dcd.top.inp > $ligname.make.protein.dcd.top.log
 wait

# Clean up the folder

 mkdir $date.prep/$ligname
 mv $ligname* $date.prep/$ligname/
 mv Q.$ligname* $date.prep/$ligname/
 cp $date.prep/$ligname/$ligname.*.top $date.$protein/
 cp $date.prep/$ligname/$ligname.fep $date.$protein/
 cp $date.prep/$ligname/$ligname.prot.lastno $date.$protein/
 done

# DONE :)

