#!/bin/bash

# By Yasmin 2009 changes made 100813 and 121101 and 121121

# This script cleans the mol2-files from the GOLD Docking session
# It then converts it into a PDB file for conversion in Maestro

 date=$( date +%y%m%d)
 dockingprogram=PLP 			#added 121121

 mkdir $date.$dockingprogram 
 mv *.mol2 $date.$dockingprogram	#changed 121121
 cd $date.$dockingprogram

 for i in *.mol2
 do
 a=$( echo "$i" | sed -e 's/\.mol2//g')
 mkdir $a

# To remove only the PDB lines from the mol2 file and create a pdb file lig.pdb
 sed -e '1,/@<TRIPOS>ATOM/d' -e '/@<TRIPOS>BOND/,$d' $a.mol2 > tmp.pdb

 sed -i 's/Br/J/g' tmp.pdb
 sed -i 's/CL/Cl/g' tmp.pdb
 sed -i 's/Cl/V/g' tmp.pdb
 sed -i 's/LP/Q/g' tmp.pdb

# To sort the Atom types
 grep "C\." tmp.pdb > C.pdb
 grep "O\." tmp.pdb > O.pdb
 grep "N\." tmp.pdb > N.pdb
 grep 'F' tmp.pdb > F.pdb
 grep 'V' tmp.pdb > Cl.pdb
 grep 'J' tmp.pdb > Br.pdb
 grep "S\." tmp.pdb > S.pdb
 grep 'H' tmp.pdb > H.pdb
 grep 'Q' tmp.pdb > LP.pdb
 grep "P\." tmp.pdb > P.pdb	#added 121121
 cat C.pdb O.pdb N.pdb F.pdb Cl.pdb Br.pdb P.pdb S.pdb H.pdb LP.pdb > lig.tmp
 rm C.pdb O.pdb N.pdb F.pdb Cl.pdb Br.pdb P.pdb S.pdb H.pdb LP.pdb

# To order the columns properly
 awk '{print $7}' tmp.pdb > HETATM.tmp
 sed -i 's/[0-9]*/HETATM/g' HETATM.tmp
 awk '{print $1}' tmp.pdb > rownumber.tmp
 awk '{print $7}' lig.tmp > LIG.tmp
 sed -i 's/[0-9]*/LIG/g' LIG.tmp
 cp LIG.tmp LIGno.tmp
 sed -i 's/LIG/1/g' LIGno.tmp
 awk '{printf "%-6s\n", $3}' lig.tmp > c1x.tmp
 cut -c1-6 c1x.tmp > c1.tmp
 awk '{printf "%-6s\n", $4}' lig.tmp > c2x.tmp
 cut -c1-6 c2x.tmp > c2.tmp 
 awk '{printf "%-7s\n", $5}' lig.tmp > c3x.tmp
 cut -c1-7 c3x.tmp > c3.tmp
 awk '{print $6}' lig.tmp > tmp.tmp
 cut -c1 tmp.tmp > marker.tmp

 paste marker.tmp rownumber.tmp > diffatomtype.tmp
  awk '{printf "%-1s%-3s\n", $1, $2}' diffatomtype.tmp > atomtype.tmp

 paste HETATM.tmp rownumber.tmp atomtype.tmp LIG.tmp LIGno.tmp c1.tmp c2.tmp c3.tmp > ihop.tmp

# Remove Lone Pairs
 grep -v 'Q' ihop.tmp > lig1.tmp
 grep 'LIG' lig1.tmp > lig.tmp   

# Clean up the file
 awk '{printf "%-9s%-4s%-4s%-8s%-7s%-8s%-7s%-7s\n", $1, $2, $3, $4, $5, $6, $7, $8}' lig.tmp > $a.pdb 

# Clean up the two-letter atom types
 sed -i 's/ J/Br/g' $a.pdb 
 sed -i 's/ V/Cl/g' $a.pdb

 rm *tmp*
 mv *$a.mol2 $a/
 cp $a.pdb ../
 mv $a.pdb $a/

wait
done

# DONE :)
