#!/bin/bash

# By Yasmin 2015-05-08

# This script generates pdb files from each frame in the trajectory.

# Set the parameters and working directories

 parameterfile=Qoplsaa.prm
 topologyfile=openstate.water.top
 dcdfile=openmd20
 framestart=5001
 framelast=10001

# Create the original Q-input file

	echo -e "rl Qoplsaa.lib" > dcd2pdb.inp
        echo -e "rl heme.lib" >> dcd2pdb.inp
#        echo -e "rl $ligname.lib" >> dcd2pdb.inp      # Comment if APO-run!
        echo -e "rff $parameterfile" >> dcd2pdb.inp
        echo -e "rt $topologyfile" >> dcd2pdb.inp
	echo -e "tr $dcdfile.dcd" >> dcd2pdb.inp
	echo -e "n" >> dcd2pdb.inp
        echo -e "rf $dcdfile.dcd" >> dcd2pdb.inp           
	echo -e "$framestart" >> dcd2pdb.inp
        echo -e "wp ${dcdfile}_$framestart.pdb" >> dcd2pdb.inp
        echo -e "y" >> dcd2pdb.inp              
        echo -e "q" >> dcd2pdb.inp

# Create the loop and run Qprep5

	for ((frame = $framestart; frame <=$framelast; frame++))
	do
	oldframe=$(($frame - 1 ))
	echo "oldframe is $oldframe and new frame is $frame"
	sed -i '' "s|$oldframe|$frame|g" dcd2pdb.inp
	qprep5 < dcd2pdb.inp > dcd2pdb.log
	done
