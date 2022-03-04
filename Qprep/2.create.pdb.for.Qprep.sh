#!/bin/bash

# By Yasmin 2010-02-23
# 2022-02-18 Edits to match LigParGen atom names

# This script creates 
# - a ligand file named Q.ligname.pdb for the water run
# - a complex file (of ligand inside the protein) named Q.ligname.complex.pdb for the protein run

 protein=Q.TEM1 # Set the name of the protein


 for i in *.mae
   do
     ligname=$( echo "$i" | sed -e 's/\.mae//g')

        # CREATE LIGAND FROM MAE-file
        grep ' " ' $ligname.mae > pdb.tmp

        # Find the number of atoms in the ligand
        awk '{print $1}' pdb.tmp > ATOMNO.tmp
        tail -1 ATOMNO.tmp > lastno.tmp
        noligatoms=$( tail lastno.tmp)

        # Create the constants ATOM, LIG and residue number for the ligand
        touch CONSTANTS.start.tmp
        touch CONSTANTS.tmp
        for ((i = 1; i <=$noligatoms; i++))
         do
           echo "ATOM LIG 1" > CONSTANTS.final.tmp
           cat CONSTANTS.start.tmp CONSTANTS.final.tmp > CONSTANTS.tmp
           cp CONSTANTS.tmp CONSTANTS.start.tmp
        done

        awk '{print $1}' CONSTANTS.tmp > ATOM.tmp
        awk '{print $2}' CONSTANTS.tmp > LIG.tmp
        awk '{print $3}' CONSTANTS.tmp > LIGRESNO.tmp
 
        # Get the coordinates of the atoms from the mae-file
        awk '{print $3" "$4" "$5}' pdb.tmp > coordinates.tmp
        awk '{printf "%-6s\n", $1}' coordinates.tmp > c1x.tmp
        cut -c1-6 c1x.tmp > c1.tmp
        awk '{printf "%-6s\n", $2}' coordinates.tmp > c2x.tmp
        cut -c1-6 c2x.tmp > c2.tmp
        awk '{printf "%-7s\n", $3}' coordinates.tmp > c3x.tmp
        cut -c1-7 c3x.tmp > c3.tmp

# Get the atom markers (C1, F10, O13, aso) from the lib-file
        sed -n -r '/atoms/,/bonds/p' $ligname.lib > atomtypes.tmp
        sed -i '1d; $d' atomtypes.tmp
        awk '{print $2}' atomtypes.tmp > markers.tmp

# Put it all together!
 paste ATOM.tmp ATOMNO.tmp markers.tmp LIG.tmp LIGRESNO.tmp c1.tmp c2.tmp c3.tmp > $ligname.tmp

 awk '{printf "%-9s%-4s%-4s%-8s%-7s%-8s%-7s%-7s\n", $1, $2, $3, $4, $5, $6, $7, $8}' $ligname.tmp > Q.$ligname.pdb

# CREATE THE COMPLEX FILE

      sed -i 's/Cl/c /g' Q.$ligname.pdb
      sed -i 's/Br/b /g' Q.$ligname.pdb

# Change the residue number of the ligand in complex with the protein
       awk '{print $5}' $protein.pdb > RESNO.tot.tmp
       sed '/^$/d' RESNO.tot.tmp > RESNO.tmp
       tail -1 RESNO.tmp > lastresno.tmp
       nores=$( tail lastresno.tmp)
       ligresno=$(($nores + 1))
       awk '{print $5}' Q.$ligname.pdb > RESNO.tmp
       sed -i "s/1/$ligresno/g" RESNO.tmp

# Change the atom numbering of the ligands
       awk '{print $2}' $protein.pdb > prot.ATOMNO.tmp
       sed '/^$/d' prot.ATOMNO.tmp > prot.noblanks.tmp
       tail -1 prot.noblanks.tmp > $ligname.prot.lastno
       protendlineno=$( tail $ligname.prot.lastno)
       end=$(echo $(($protendlineno + $noligatoms)))
       startlineno=$(($protendlineno + 1))
 
       seq $startlineno 1 $end > ATOMNO.tmp

# Put it all together!
 paste ATOM.tmp ATOMNO.tmp markers.tmp LIG.tmp RESNO.tmp c1.tmp c2.tmp c3.tmp > $ligname.complex.tmp

 awk '{printf "%-7s%-6s%-4s%-6s%-9s%-8s%-7s%-7s\n", $1, $2, $3, $4, $5, $6, $7, $8}' $ligname.complex.tmp > Q.$ligname.complex.tmp

 cat $protein.pdb Q.$ligname.complex.tmp > Q.$ligname.complex.pdb
       
 sed -i 's/c /Cl/g' Q.$ligname.complex.pdb
 sed -i 's/b /Br/g' Q.$ligname.complex.pdb
 sed -i 's/b /Br/g' Q.$ligname.pdb
 sed -i 's/c /Cl/g' Q.$ligname.pdb

rm *tmp*

 done 
 


 
