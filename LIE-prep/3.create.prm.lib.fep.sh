#!/bin/bash

# By Yasmin 2014-06-13 

# This script creates parameter and lib files from Masouds mae2q binary

# Set the path to the SCHRODINGER utilities

 	export FFL=/home/apps/schrodinger2013/utilities

# Start the loop generating lib and param files using the pre-generated .mae-files

	for i in *.mae
   	  do
     		ligname=$( echo "$i" | sed -e 's/\.mae//g')
        	$FFL/ffld_server -imae $ligname.mae -print_parameters -version 14 > out
		./mae2q out 

# SPLIT the generated PARAMETER file

		sed -n '/X vdw/,/X bond/p' X.parm > X.vdw.tmp
		sed -n '/X bond/,/X angle/p' X.parm > X.bond.tmp
		sed -n '/X angle/,/X proper/p' X.parm > X.angle.tmp
		sed -n '/X proper/,/X improper/p' X.parm > X.torsion.tmp
		sed -n '/X improper/,$p' X.parm > X.improper.tmp

# CAT all parameter files to one

		cat PARAMETERS/Qoplsaa.HEM.vdw.prm X.vdw.tmp PARAMETERS/Qoplsaa.HEM.bond.prm X.bond.tmp PARAMETERS/Qoplsaa.HEM.angle.prm X.angle.tmp PARAMETERS/Qoplsaa.HEM.torsion.prm X.torsion.tmp PARAMETERS/Qoplsaa.HEM.improper.prm X.improper.tmp > $ligname.prm 
	
# EDIT the LIB-file

		mv X.lib $ligname.lib

# CREATE the FEP-file

		cp $ligname.lib $ligname.lib.tmp
		sed '1,5d' $ligname.lib.tmp > clean.$ligname.lib.tmp
		sed -n '/atoms/,/bonds/p' clean.$ligname.lib.tmp > fep.tmp
		awk '{print $1}' fep.tmp > column.tmp
		paste column.tmp column.tmp > fep.$ligname.tmp
		sed '1d' fep.$ligname.tmp > noheader.tmp
		sed '$d' noheader.tmp > nofooter.tmp
		sed '$d' nofooter.tmp > noblankspace.tmp
		cat FEP.header noblankspace.tmp > $ligname.fep

# CLEAN all the TMP-files

		rm *.tmp
		rm out
		rm X.parm

# End the loop
 done

