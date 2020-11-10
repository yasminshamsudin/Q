#!/bin/bash

# By Yasmin 2015-01-11

# This script analyzes all the PMF calculations using Masouds version of Qfep here named qpmf
# It creates the input file and runs qpmf. The generated output files are collated and the replicates are clustered using Masouds cluster script. 

 wdir=/Volumes/YK-56/Gupta/GUPTA-PMF
 
 date=160429
 protein=Gupta

 cd $wdir/$date.$protein
 mkdir $wdir/$date.$protein.results

# NO MORE EDITING!!

 for a in *
	do
	 tmpdir=$( echo "$a" )
	 cd $tmpdir/pmf/
     cp $wdir/qpmf.inp .

# RUN Qpmf

	qpmf < qpmf.inp > qpmf.results

	cp qpmf.results $wdir/$date.$protein.results/$tmpdir.results

	cd $wdir/$date.$protein
	done

# Cluster all

	cd $wdir/$date.$protein.results/
	for a in *.results
	 do 
	 result=$( echo "$a" )
	 sed -e '1,/<r_xy>/d' $result > $result.tmp # cuts out Part 3 for analysis
	 echo "" >> $result.tmp		# adds a blank line at the end of all tmp files
	 done

# Housekeeping

	find . -empty -delete 		# deletes the blank files
	cat *.tmp > all.results		# put everything together
	echo -e "$(ls *.tmp)" > successful.runs # documents which runs finished
	rm *.tmp

# Run mac.cluster (in my path)

#	/Applications/150409.mac.cluster all.results > $date.$protein$direction.pmfclusteredresults
#	rm all.results

# DONE 
