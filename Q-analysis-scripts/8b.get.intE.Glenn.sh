#!/bin/bash

# Created by Yasmin 2012-01-16 EDITED 2014-07-04- NEEDS MORe EDITING!!!
# This script extracts all the interaction Energies from the dcd-files

 wdir=~/COX-2
 date=140616
 protein=Q.hCOX2L
 dockingprogram=MAN
 cluster=glenn
 seed=1

# NO MORE EDITING!

 

 prep=$date.$protein
 results=$date.$protein.$dockingprogram 
 analysis=$date.$protein.$dockingprogram.analysis

cd $results/

 for b in *
        do
        batchname=$( echo "$b" )
        cd $batchname/ 
	mkdir $wdir/$analysis/$batchname.intE/

 	for i in *
   	do
     		ligname=$( echo "$i" )
		cd $wdir/$prep/$date.$dockingprogram/$ligname
		awk '{print $5}' $ligname.protein.top.pdb > RESNO.tmp
 		tail -1 RESNO.tmp > lastRESno.tmp
 		lastRESno=$( tail lastRESno.tmp)

		cd $wdir/$results/$batchname/$ligname

echo -e $ligname.protein.top'\n'8'\n'1'\n'$lastRESno'\n'residue 553'\n'end'\n'go'\n'Protein/md1.dcd'\n'Protein/md2.dcd'\n'Protein/md3.dcd'\n'Protein/md4.dcd'\n'Protein/md5.dcd'\n'Protein/md6.dcd'\n'Protein/md7.dcd'\n'Protein/md8.dcd'\n'Protein/md9.dcd'\n'Protein/md10.dcd'\n'. > $ligname.getintE.$date.inp

		rm $wdir/$prep/$date.$dockingprogram/$ligname/*.tmp

		wait

		Qcalc5 < $ligname.getintE.$date.inp > $wdir/$analysis/$batchname.intE/$ligname.$date.intE.log

		cd ..

	done

cd $wdir/$results/
done
