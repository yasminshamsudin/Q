#!/bin/bash

# By Yasmin 2015-01-11

# This script analyzes all the PMF calculations using Masouds version of Qfep here named qpmf
# It creates the input file and runs qpmf. The generated output files are collated and the replicates are clustered using Masouds cluster script. 

 wdir=/Volumes/YK-34/Gupta/GUPTA-PMF
 
 date=160226
 protein=Gupta
# direction=OtC
# replicates=1

# QFEP properties
  states=2
  offdiags=0
  kT=0.596
  skippts=1000
  bins=70
  minbinpts=10
  alpha2=0
  diagelem=1
  i=1 j=2 Aij=00 my=0 ny=0 rij=0

 cd $wdir/$date.$protein
 mkdir $wdir/$date.$protein.results

# NO MORE EDITING!!

 for a in *
	do
	 tmpdir=$( echo "$a" )
	 cd $tmpdir/pmf/

	 files=$( wc qfep_list.inp | awk '{ print $1 }')

	echo -e "$files          # of files" > qpmf.head
	echo -e "$states $offdiags          # of states, # off-diags" >> qpmf.head
	echo -e "$kT $skippts   # kT & no. pts to skip" >> qpmf.head
	echo -e "$bins           # bins (not used here)" >> qpmf.head
	echo -e "$minbinpts           # minimum # bin points (not used here)" >> qpmf.head
	echo -e "$alpha2            # alfa(s) for state 2" >> qpmf.head
	echo -e "$diagelem            # no of diag elem" >> qpmf.head
	echo -e "$i $j $Aij $my $ny $rij # i j Aij my ny rij" >> qpmf.head
	echo -e "1  -1        #lin. comb. of states def. reac. coord." >> qpmf.head

	cat qpmf.head qfep_list.inp > qpmf.inp

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
