#!/bin/bash

# Created by Yasmin 111208 modified 120113 and 120123

 parameters=/Volumes/4TB/COX-PREP/PARAMETERS
 wdir=/Volumes/4TB/COX1/LIE
 results=Analysis-structures
 analysis=averagestructures

mkdir $analysis
cd $results/

for i in *
   	do
     	ligname=$( echo "$i" )
	cd $ligname

echo -e rl $parameters/Qoplsaa.lib > $wdir/$results/$ligname/makeave1to5.$ligname.inp
echo -e rl $parameters/heme.lib >> $wdir/$results/$ligname/makeave1to5.$ligname.inp
echo -e rl $ligname.lib >> $wdir/$results/$ligname/makeave1to5.$ligname.inp
echo -e rff $ligname.prm >> $wdir/$results/$ligname/makeave1to5.$ligname.inp
echo -e rt $ligname.protein.top y >> $wdir/$results/$ligname/makeave1to5.$ligname.inp
echo -e av Protein/md1.dcd y y >> $wdir/$results/$ligname/makeave1to5.$ligname.inp
echo -e Protein/md2.dcd y y >> $wdir/$results/$ligname/makeave1to5.$ligname.inp
echo -e Protein/md3.dcd y y >> $wdir/$results/$ligname/makeave1to5.$ligname.inp
echo -e Protein/md4.dcd y y >> $wdir/$results/$ligname/makeave1to5.$ligname.inp
echo -e Protein/md5.dcd y n >> $wdir/$results/$ligname/makeave1to5.$ligname.inp
echo -e a.$ligname.$date.1-5.pdb y >> $wdir/$results/$ligname/makeave1to5.$ligname.inp
echo -e q >> $wdir/$results/$ligname/makeave1to5.$ligname.inp

cp $wdir/$results/$ligname/makeave1to5.$ligname.inp $wdir/$results/$ligname/makeave6to10.$ligname.inp
sed -i '' 's/md1/md6/g' $wdir/$results/$ligname/makeave6to10.$ligname.inp
sed -i '' 's/md2/md7/g' $wdir/$results/$ligname/makeave6to10.$ligname.inp
sed -i '' 's/md3/md8/g' $wdir/$results/$ligname/makeave6to10.$ligname.inp
sed -i '' 's/md4/md9/g' $wdir/$results/$ligname/makeave6to10.$ligname.inp
sed -i '' 's/md5/md10/g' $wdir/$results/$ligname/makeave6to10.$ligname.inp
sed -i '' 's/1-5/6-10/g' $wdir/$results/$ligname/makeave6to10.$ligname.inp

wait

Qprep5 < $wdir/$results/$ligname/makeave1to5.$ligname.inp > $wdir/$analysis/ave1-5.$ligname.log
Qprep5 < $wdir/$results/$ligname/makeave6to10.$ligname.inp > $wdir/$analysis/ave6-10.$ligname.log

wait

mv $wdir/$results/$ligname/a.$ligname.*.pdb $wdir/$analysis/

cd $wdir/$results/

done 
