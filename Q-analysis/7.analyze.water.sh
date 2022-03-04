#!/bin/bash

# By Yasmin 2009-11-26 edited 2013-01-07

# This script analyzes all the water runs in the folder dated today

  date=130103
# date=$( date +%y%m%d)
  protein=Q.hCOX1
  cluster=Trio
  scoringfunction=PLP
 
 results=$date.$protein.$scoringfunction.$cluster.results
 analysis=$date.water.$scoringfunction.analysis #added and changed 2013-01-07

 cd $results

 for i in * 
     do
     ligname=$( echo "$i" )
     cd $ligname/Water/water$date$ligname/
     perl ~/COX/yasmin.watres.pl
     wait
     cd ~/COX/$results/
     done

# Water results

 mkdir ~/COX/$analysis/
  cd ~/COX/$results/
  cp ../H2O.resultatfil ../$analysis/end.total.resultat
   for n in *
     do
     ligname=$( echo "$n" )
     cp ../$analysis/end.total.resultat ../$analysis/start.total.resultat

     cd $ligname/Water/water$date$ligname/
     sed -ne "/Total average/{n;p;n;p;}" H2O.resultat.txt > tot.tmp
     sed -ne "/1 part/{n;p;n;p;}" H2O.resultat.txt > av1.tmp
     sed -ne "/2 part/{n;p;n;p;}" H2O.resultat.txt > av2.tmp
     sed -ne "/minus/{n;p;n;p;}" H2O.resultat.txt > error.tmp
     paste tot.tmp av1.tmp av2.tmp error.tmp > test.tmp
     tail -1 test.tmp > resultat.tmp
     awk '{printf "%-11s%-11s%-11s%-11s%-11s%-11s%-7s%-7s\n", $1, $2, $5, $6, $9, $10, $13, $14}' resultat.tmp > $ligname.resultat.tmp
     echo $ligname > $ligname.tmp
     paste $ligname.tmp $ligname.resultat.tmp > $ligname.resultat.klar.tmp
     cat ~/COX/$date.water.analysis/start.total.resultat $ligname.resultat.klar.tmp > ~/COX/$analysis/end.total.resultat
     rm *.tmp
     cd ~/COX/$results/
     done
  mv ../$analysis/end.total.resultat ../$analysis/$date.H2O.results

  rm ../$analysis/start.total.resultat

# DONE
 

