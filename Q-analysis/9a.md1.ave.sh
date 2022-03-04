#!/bin/bash

# Created by Yasmin 111208 modified 120113 and 120123

 wdir=~/COX
 date=130913
 protein=Q.hCOX1
# cluster=Kalkyl
 seed=s4
 dockingprogram=XRAY
 parameters=$date.$dockingprogram
 prep=$date.$protein.$dockingprogram
 results=$date.$protein.$dockingprogram.$seed.results
 analysis=$date.$protein.$dockingprogram.$seed.analysis

mkdir $analysis
cd $results/

for i in *
   	do
     	ligname=$( echo "$i" )
	cd $ligname
	cp $wdir/$parameters/$ligname/$ligname.lib .
	cp $wdir/$parameters/$ligname/$ligname.prm .

echo -e rl $wdir/Qoplsaa.lib'\n'rl $wdir/heme.lib'\n'rl $ligname.lib'\n'rff $ligname.prm'\n'rt $ligname.protein.top y'\n'av Protein/md1.dcd y n'\n'a.$ligname.$date.md1.pdb y'\n'q > makeavemd1.$ligname.$date.inp

wait

Qprep5 < makeavemd1.$ligname.$date.inp > $wdir/$analysis/avemd1.$ligname.$date.log

wait

mv a.$ligname.$date.md1.pdb $wdir/$analysis/

cd $wdir/$results/

done 
