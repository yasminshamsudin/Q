#!/bin/bash

# Created by Yasmin 111208 modified 120113

 date=120327
 protein=Q.hCOX1
 cluster=Neo
 results=$date.$protein.$cluster.results
 analysis=$date.water.analysis

mkdir $analysis/$date.average/

cd $results/

 for i in *
   do
     ligname=$( echo "$i" )

cd $ligname

echo -e rl /home/yasmin/COX/Qoplsaa.lib'\n'rl /home/yasmin/COX/heme.lib'\n'rl /home/yasmin/COX/$date/$ligname/$ligname.lib'\n'rff /home/yasmin/COX/$date/$ligname/$ligname.prm'\n'rt /home/yasmin/COX/$date/$ligname/$ligname.water.top y'\n'av Water/md1.dcd y y'\n'Water/md2.dcd y y'\n'Water/md3.dcd y y'\n'Water/md4.dcd y y'\n'Water/md5.dcd y y'\n'Water/md6.dcd y y'\n'Water/md7.dcd y n'\n'~/COX/$analysis/$date.average/a.$ligname.$date.pdb y'\n'q > makeave.water.$ligname.$date.inp


wait

Qprep5 < makeave.water.$ligname.$date.inp > ~/COX/$analysis/$date.average/makeave.water.$ligname.$date.log

wait

cd ..

done 
