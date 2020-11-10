#!/bin/bash 

# By Yasmin 2009 altered 2010-03-02
 
# This script creates maketop-files for ligans in water and protein and their respective dcd-pdb-files. Finally it runs Qprep5 for all systems and cleans the directory.

# date=140212i
 date=$( date +%y%m%d)
 protein=Q.hCOX1L
 dockingprogram=MAN

 mkdir $date.$dockingprogram
 mkdir $date.$protein.$dockingprogram

 for i in *.mae
 do
 ligname=$( echo "$i" | sed -e 's/\.mae//g')
 radius=20.0            # Set Radius
 target="$protein"      # Give Target name

# Set x, y, z coordinates

# x=26.026  y=23.663  z=16.171
 x=26.387  y=34.363  z=201.281	
# x=25.98   y=33.163  z=202.843  


########################### No MORE CHANGES AFTER THIS POINT!!! ##################

# Create maketop-files
# Please NOTE addition of heme.lib!

 echo -e rl PARAMETERS/Qoplsaa.lib'\n'rl PARAMETERS/heme.lib'\n'rl $ligname.lib'\n'rff $ligname.prm'\n'rp Q.$ligname.pdb'\n'boundary sphere $x $y $z $radius'\n'solvate boundary 20.3 1 HOH'\n'mt $ligname $target $radius A'\n'wt $ligname.water.top'\n'wp $ligname.water.top.pdb y'\n'quit > $ligname.water.maketop.inp

 echo -e rff $ligname.prm'\n'rt $ligname.water.top'\n'boundary sphere $x $y $z $radius'\n'ma none'\n'ma not excluded'\n'mt $ligname $target $radius A'\n'wp $ligname.water.dcd_top.pdb y'\n'quit > $ligname.make.water.dcd.top.inp

 echo -e rl PARAMETERS/Qoplsaa.lib'\n'rl PARAMETERS/heme.lib'\n'rl $ligname.lib'\n'rff $ligname.prm'\n'rp Q.$ligname.complex.pdb'\n'boundary sphere $x $y $z $radius'\n'solvate boundary 20.3 1 HOH'\n'mt $ligname $target $radius A'\n'wt $ligname.protein.top'\n'wp $ligname.protein.top.pdb y'\n'quit > $ligname.protein.maketop.inp

 echo -e rff $ligname.prm'\n'rt $ligname.protein.top'\n'boundary sphere $x $y $z $radius'\n'ma none'\n'ma not excluded'\n'mt $ligname $target $radius A'\n'wp $ligname.protein.dcd_top.pdb y'\n'quit > $ligname.make.protein.dcd.top.inp

# Run Qprep5

 Qprep5 < $ligname.water.maketop.inp > $ligname.water.top.log
 wait
 Qprep5 < $ligname.make.water.dcd.top.inp > $ligname.make.water.dcd.top.log
 wait
 Qprep5 < $ligname.protein.maketop.inp > $ligname.protein.top.log
 wait
 Qprep5 < $ligname.make.protein.dcd.top.inp > $ligname.make.protein.dcd.top.log
 wait

# Clean up the folder

 cd $date.$dockingprogram/
 mkdir $ligname
 cd ..
 mv $ligname* $date.$dockingprogram/$ligname/
 mv Q.$ligname* $date.$dockingprogram/$ligname/
 cp $date.$dockingprogram/$ligname/$ligname.*.top $date.$protein.$dockingprogram/
 cp $date.$dockingprogram/$ligname/$ligname.fep $date.$protein.$dockingprogram/
 cp $date.$dockingprogram/$ligname/$ligname.prot.lastno $date.$protein.$dockingprogram/
 done

# DONE :)

