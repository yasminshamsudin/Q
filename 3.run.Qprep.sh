#!/bin/bash 

# By Yasmin 2009 altered 2010-03-02
# 2022-02-18 Edited to fit new formating (Q.lib & Q.parm)
 
# This script creates: 
# - maketop-files for ligands in water and protein 
# - the respective dcd-files
# Finally it runs Qprep5 for all systems and cleans the directory.

# date=140212i
 date=$( date +%y%m%d)
 protein=TEM1     # Give protein name
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

 echo -e rl PARAMETERS/Qoplsaa.lib'\n'rl Q.$ligname.CM1A.lib'\n'rff Q.$ligname.prm'\n'rp Q.$ligname.pdb'\n'boundary sphere $x $y $z $radius'\n'solvate boundary $boundary 1 HOH'\n'mt $ligname $protein $radius A'\n'wt $ligname.CM1A.water.top'\n'wp $ligname.CM1A.water.top.pdb y'\n'quit > $ligname.CM1A.water.maketop.inp
 echo -e rl PARAMETERS/Qoplsaa.lib'\n'rl Q.$ligname.O5.lib'\n'rff Q.$ligname.prm'\n'rp Q.$ligname.pdb'\n'boundary sphere $x $y $z $radius'\n'solvate boundary $boundary 1 HOH'\n'mt $ligname $protein $radius A'\n'wt $ligname.O5.water.top'\n'wp $ligname.O5.water.top.pdb y'\n'quit > $ligname.O5.water.maketop.inp

 echo -e rl PARAMETERS/Qoplsaa.lib'\n'rl Q.$ligname.CM1A.lib'\n'rff Q.$ligname.prm'\n'rp Q.$ligname.complex.pdb'\n'boundary sphere $x $y $z $radius'\n'solvate boundary $boundary 1 HOH'\n'mt $ligname $protein $radius A'\n'wt $ligname.CM1A.protein.top'\n'wp $ligname.CM1A.protein.top.pdb y'\n'quit > $ligname.CM1A.protein.maketop.inp
 echo -e rl PARAMETERS/Qoplsaa.lib'\n'rl Q.$ligname.O5.lib'\n'rff Q.$ligname.prm'\n'rp Q.$ligname.complex.pdb'\n'boundary sphere $x $y $z $radius'\n'solvate boundary $boundary 1 HOH'\n'mt $ligname $protein $radius A'\n'wt $ligname.O5.protein.top'\n'wp $ligname.O5.protein.top.pdb y'\n'quit > $ligname.O5.protein.maketop.inp

 echo -e rff $ligname.prm'\n'rt $ligname.CM1A.protein.top'\n'boundary sphere $x $y $z $radius'\n'ma none'\n'ma not excluded'\n'mt $ligname $protein $radius A'\n'wp $ligname.$protein.dcd_top.pdb y'\n'quit > $ligname.CM1A.make.protein.dcd.top.inp
 echo -e rff $ligname.prm'\n'rt $ligname.O5.protein.top'\n'boundary sphere $x $y $z $radius'\n'ma none'\n'ma not excluded'\n'mt $ligname $protein $radius A'\n'wp $ligname.$protein.dcd_top.pdb y'\n'quit > $ligname.O5.make.protein.dcd.top.inp

# Run Qprep5

 qprep5 < $ligname.CM1A.water.maketop.inp > $ligname.CM1A.water.top.log
 qprep5 < $ligname.CM1A.protein.maketop.inp > $ligname.CM1A.protein.top.log
 qprep5 < $ligname.CM1A.make.protein.dcd.top.inp > $ligname.CM1A.make.protein.dcd.top.log

 qprep5 < $ligname.O5.water.maketop.inp > $ligname.O5.water.top.log
 qprep5 < $ligname.O5.protein.maketop.inp > $ligname.O5.protein.top.log
 qprep5 < $ligname.O5.make.protein.dcd.top.inp > $ligname.O5.make.protein.dcd.top.log

# Clean up the folder

 mkdir $date.prep/$ligname
 mv $ligname* $date.prep/$ligname/
 mv Q.$ligname* $date.prep/$ligname/
 cp $date.prep/$ligname/$ligname.*.top $date.$protein/
 cp $date.prep/$ligname/$ligname.fep $date.$protein/
 cp $date.prep/$ligname/$ligname.prot.lastno $date.$protein/
 done

# DONE :)

