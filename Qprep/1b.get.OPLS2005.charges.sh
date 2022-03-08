#!/bin/bash

# By Yasmin 2022-03-07 
# An installation of Maestro is needed (academic version can be obtained for free)
# This script uses the vdw parameters from LigParGen and OPLS2005 charges from MacroModel
# Ligands should be built in Maestro and charges should be checked before exported as .mae files

# Set the path to the SCHRODINGER utilities

 	export FFL=/home/yasmin/schrodinger2021-3/utilities

################ No More Editing !!! ##########################

# Start the loop generating lib and param files using the pre-generated .mae-files

	for i in *.mae
   	  do
     		ligname=$( echo "$i" | sed -e 's/\.mae//g')
        	$FFL/ffld_server -imae $ligname.mae -print_parameters -version 14 > $ligname.OPLS2005.tmp

			# Extract the charges
			sed -n -r '/OPLSAA/,/^\s*$/p' $ligname.OPLS2005.tmp > OPLS2005.tmp	# Get everything from OPLSAA until end of section

			# Clean up charges
			sed -i '1,4d' OPLS2005.tmp # Remove rows 1-4
			awk '{ print $5}' OPLS2005.tmp > $ligname.charges.tmp
	
			# Create the new LIB-file
            sed -n -r '1,/atoms/p' Q.$ligname.CM1A.lib > header.tmp # Extract from 1st line to keyword
			sed -n -r '/atoms/,/bonds/p' Q.$ligname.CM1A.lib> totalcharge.tmp
            sed -i '1d; $d' totalcharge.tmp 
			awk '{print $1"    "$2"   "$3"  "}' totalcharge.tmp > atomtypes.tmp
            paste atomtypes.tmp $ligname.charges.tmp > atoms.tmp
            sed -i '$ d' atoms.tmp
            sed -n -r '/bonds/,//p' Q.$ligname.CM1A.lib> bottom.tmp
            cat header.tmp atoms.tmp bottom.tmp > Q.$ligname.O5.lib

            # CLEAN all the TMP-files

		    rm *.tmp

            # End the loop
        done