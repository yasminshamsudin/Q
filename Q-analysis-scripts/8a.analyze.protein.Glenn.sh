#!/bin/bash

# By Yasmin 2009-11-26 modified 2012-01-13

# This script analyzes all the protein runs in the specified folder
# It then collects all protein results data into one file.

 wdir=~/COX-2
 date=140707
 protein=Q.hCOX1L
 dockingprogram=MAN
 seedstart=6
 seedfinish=10

# NO MORE EDITING!

 mkdir $date.$protein.$dockingprogram

 mv $date.$protein.$dockingprogram.s* $date.$protein.$dockingprogram/

 analysis=$date.$protein.$dockingprogram.analysis
 mkdir $wdir/$analysis/
 
 for (( seed=$seedstart; seed<=$seedfinish; seed++ ))

 do

 results=$date.$protein.$dockingprogram/$date.$protein.$dockingprogram.s$seed 

 cd $wdir/$results

 for i in * 
     do
     ligname=$( echo "$i" )
     cd $ligname/Protein/prot$date$ligname/
     perl $wdir/yasmin.protres.pl
     wait
     cd $wdir/$results/
     done

# Protein results

  cd $wdir/$results/
  cp $wdir/prot.resultatfil $wdir/$analysis/end.total.resultat
   for n in *
     do
     ligname=$( echo "$n" )
     cp $wdir/$analysis/end.total.resultat $wdir/$analysis/start.total.resultat
    
     cd $ligname/Protein/prot$date$ligname/
     sed -ne "/Total average/{n;p;n;p;}" prot.resultat.txt > tot.tmp
     sed -ne "/1 part/{n;p;n;p;}" prot.resultat.txt > av1.tmp
     sed -ne "/2 part/{n;p;n;p;}" prot.resultat.txt > av2.tmp
     sed -ne "/minus/{n;p;n;p;}" prot.resultat.txt > error.tmp
     paste tot.tmp av1.tmp av2.tmp error.tmp > test.tmp
     tail -1 test.tmp > resultat.tmp
     awk '{printf "%-11s%-11s%-11s%-11s%-11s%-11s%-7s%-7s\n", $1, $2, $5, $6, $9, $10, $13, $14}' resultat.tmp > $ligname.resultat.tmp
     echo $ligname > $ligname.tmp
     paste $ligname.tmp $ligname.resultat.tmp > $ligname.resultat.klar.tmp
     cat $wdir/$analysis/start.total.resultat $ligname.resultat.klar.tmp > $wdir/$analysis/end.total.resultat
     rm *.tmp
     cd $wdir/$results/
     done
  mv $wdir/$analysis/end.total.resultat $wdir/$analysis/$date.prot.$dockingprogram.s$seed.results

  rm $wdir/$analysis/start.total.resultat

 done

# DONE

