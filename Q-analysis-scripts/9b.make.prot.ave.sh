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

echo -e rl $wdir/Qoplsaa.lib'\n'rl $wdir/heme.lib'\n'rl $ligname.lib'\n'rff $ligname.prm'\n'rt $ligname.protein.top y'\n'av Protein/md1.dcd y y'\n'Protein/md2.dcd y y'\n'Protein/md3.dcd y y'\n'Protein/md4.dcd y y'\n'Protein/md5.dcd y n'\n'a.$ligname.$date.1-5.pdb y'\n'q > makeave1to5.$ligname.$date.inp

cp makeave1to5.$ligname.$date.inp makeave6to10.$ligname.$date.inp
sed -i 's/md1/md6/g' makeave6to10.$ligname.$date.inp
sed -i 's/md2/md7/g' makeave6to10.$ligname.$date.inp
sed -i 's/md3/md8/g' makeave6to10.$ligname.$date.inp
sed -i 's/md4/md9/g' makeave6to10.$ligname.$date.inp
sed -i 's/md5/md10/g' makeave6to10.$ligname.$date.inp

wait

Qprep5 < makeave1to5.$ligname.$date.inp > $wdir/$analysis/ave1-5.$ligname.$date.log
Qprep5 < makeave6to10.$ligname.$date.inp > $wdir/$analysis/ave6-10.$ligname.$date.log

wait

mv a.$ligname.$date.*.pdb $wdir/$analysis/

cd $wdir/$results/

done 
