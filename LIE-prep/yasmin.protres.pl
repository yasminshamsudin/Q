#!/usr/bin/perl
#resultat
#=======

#by Martin Nervall, 2004

#Extracts q-atom-surrounding energies from qdyn log files named mdXX.log and
# save energies in mdXX.dat 
#Can extract total energies to same .dat-file
#Calculates mean energies
#Plot 

#usage
#resultat [-v] [-t] [-z] [-q] [-s state]  xx1, xx2 (from logfile xx1 to xx2, leave blank for all) 
#-d                    : delete all but the first logfile,i.e. save only first logfile
#                      : save extacted energies in mdXX.dat
#-p                    : do not plot with gnuplot
#-w=<int>              : show plot <int> seconds  
#-u                    : use data from .dat files
#-a=<int>,-subavg<int> : number of subaverages to calculate 
#-t,total              : do not print total energy in col#4 and potential energy in col#5
#-s, state	       : select FEP state state, default the one with lambda=1
#-z                    : zip all log-files
#-h                    : help

#-q, -quiet            : suppresses printing of filenames to stderr
#-version	       : sets qdyn version (normally read from log file)
#
#logfiles: list of filenames which should be valid enzymix log files

$endhelp = __LINE__-1;
($mypath) = __FILE__ =~/(.*)\/resultat/;

use Getopt::Long;
GetOptions("h|help", "p|plot", "d|delete", "u|use_dat", "s|state", "t|total", "a|subavg=i", "w|wait=i", "z|zip");
$root=`pwd`;

if(defined($opt_h)) {
    system("head -$endhelp $0");
    exit;
}
open(OUTFILE,">prot.resultat.txt") || die "Cannot open : prot.resultat.txt!\n";  


#--------------------------------------------------------------------
# If .not. -u: make .dat-files from .log-files
# Extract q-surr and total energies. 
#--------------------------------------------------------------------

if (!defined(${opt_u})){ #if not -u (use .dat-files) .....
    
    if(defined($opt_s)) {
	$match_qsurr = '^Q-surr\.\s+${opt_s} [\d\.]+\s+(-?[\d\.]+)\s+(-?[\d\.]+)';
	print "opt_s: ${opt_s}n";
    }
    else {
	$match_qsurr = '^Q-surr\.\s+\d 1\.0+\s+(-?[\d\.]+)\s+(-?[\d\.]+)';
    }
    

    if(scalar(@ARGV) == 0) { #read all logfiles
	print "Using all log files.\n";
	$num = 1;
	@logfiles = `ls md*.log`;    
	$num2=0;
	foreach(@logfiles){
	    $num2+=/md[\d]+\.log/;
	}
    }
    else {
	$num=@ARGV[0];
	$num2=@ARGV[1];
    }
    $filecount = $num;
    while($filecount<=$num2) {
	$file = "md${filecount}.log";
	unless(open(LOGFILE, $file)) {
	    print stderr "${file} not found!\n"; 
	    print stderr "Trying .dat-files.....\n"; 
	    goto(DAT);
	}
	print "Processing file $file\n";
	open(DATFILE, ">md${filecount}.dat") || die "Cannot open : md${filecount}.dat!\n";
	&extr_qdyn;
	close(LOGFILE);
	$filecount++;
	close(DATFILE);
    }
} #end if (!defined(opt_u))
    
    
#--------------------------------------------------------------------
# Clean up logfiles. Keep first logfile.
#--------------------------------------------------------------------
    if (defined(${opt_d})){ #if -d, clean logfiles
	system("mv md1.log tmp");
	system("rm md*.log");
	system("rm eq*.log");
	system("rm -f md1.log.gz");
	system("mv tmp md1.log");
	system("gzip md1.log");
    }
#--------------------------------------------------------------------
# Zip and keep all logfiles.
#--------------------------------------------------------------------
    if (defined(${opt_z})){ #if -z, zip logfiles
    	system("rm -f md*.log.gz");
    	system("gzip *.log");
    	system("rm -f eq*.log");
    }	
    


#--------------------------------------------------------------------
# Now read from .dat-files and calculate averages
#--------------------------------------------------------------------
 DAT:
    my $e_el_sum;
my $e_vdw_sum;
my $e_tot_sum;
if (defined(${opt_u})){ #if -u, first get indata .
    if(scalar(@ARGV) == 0) { #read all logfiles
	print "Using all dat files.\n";
	$num = 1;
	@logfiles = `ls md*.dat`;    
	$num2=0;
	foreach(@logfiles){
	    $num2+=/md[\d]+\.dat/;
	}
    }
    else {
	$num=@ARGV[0];
	$num2=@ARGV[1];
    }
}
#First calculate total average
$filecount = $num;
$time_offset=0;
$time=0;
open(PLOTFILE,">prot.plot.txt") || die "Cannot open : tmp.txt!\n";  
while($filecount<=$num2) { #main loop
    open(DATFILE,"<md${filecount}.dat") || die "Cannot open : md${filecount}.dat!\n";  
    print "Processing file md${filecount}.dat\n";
    $time_offset += $time;
    while($_ = <DATFILE>){
	($e_vdw, $e_el, $time, $e_tot, $e_pot) = split /\s+/;
	$e_vdw_sum += $e_vdw;
	$e_el_sum += $e_el;
	$e_tot_sum += $e_tot;
	$e_pot_sum += $e_pot;
	printf PLOTFILE " %9.2f %9.2f %9.2f %9.2f %9.2f\n",$e_vdw, $e_el, $time+$time_offset, $e_tot, $e_pot;
    }
    $filecount++;	
}
$tot_ave_vdw = $e_vdw_sum/$.;	
$tot_ave_el = $e_el_sum/$.;	
$tot_ave_tot = $e_tot_sum/$.;
$tot_ave_pot = $e_pot_sum/$.;
$total_count = $.;	
print OUTFILE "Calculated averages from $num to $num2.\n";
print OUTFILE "Total average:\n";
print OUTFILE "    Vdw        El       Total     Potential\n";
printf OUTFILE " %9.2f %9.2f %9.2f %9.2f\n", $tot_ave_vdw, $tot_ave_el, $tot_ave_tot, $tot_ave_pot;
print OUTFILE "\n";
close(DATFILE);

#Now caculate sub-averages, two or more
if (defined($opt_a)) {$n_means = ${opt_a};}
else {$n_means = 2;}
$filecount=$num;
$.=0;
for ($i=1;$i<=$n_means;$i++){
    $avg_count = $total_count*$i/$n_means;
    $e_vdw_sum = 0;
    $e_el_sum = 0;
    $e_tot_sum = 0;
    $e_pot_sum = 0;
    while($.< $avg_count) {
	if ($_ = <DATFILE>) {} #if not end of file
	else{                  #else open next file
	    open(DATFILE,"<md${filecount}.dat") || die "Cannot open : md${filecount}.dat!\n";
	    $filecount++;
	    $_ = <DATFILE>;
	}
	($e_vdw, $e_el, $time, $e_tot, $e_pot) = split /\s+/;
	$e_vdw_sum += $e_vdw;
	$e_el_sum += $e_el;
	$e_tot_sum += $e_tot;
	$e_pot_sum += $e_pot;
    }
    $ave_vdw[$i] = $e_vdw_sum/$total_count*$n_means;	
    $ave_el[$i] = $e_el_sum/$total_count*$n_means;	
    $ave_tot[$i] = $e_tot_sum/$total_count*$n_means;
    $ave_pot[$i] = $e_pot_sum/$total_count*$n_means;
    print OUTFILE "Calculated average of $i part:\n";
    print OUTFILE "    Vdw        El       Total     Potential\n";
    printf OUTFILE " %9.2f %9.2f %9.2f %9.2f\n", $ave_vdw[$i], $ave_el[$i], $ave_tot[$i], $ave_pot[$i];
}

#Calculate mean error (is this the meassure you want??)
for ($i=1;$i<=$n_means;$i++){
    $vdw_mean_err += sqrt(($tot_ave_vdw - $ave_vdw[$i])**2);
    $el_mean_err += sqrt(($tot_ave_el - $ave_el[$i])**2);
    $tot_mean_err += sqrt(($tot_ave_tot - $ave_tot[$i])**2); 
    $pot_mean_err += sqrt(($tot_ave_pot - $ave_pot[$i])**2);     
}

if ($n_means == 2) {
    $vdw_mean_err = $vdw_mean_err;
    $el_mean_err = $el_mean_err; 
    $tot_mean_err = $tot_mean_err; 
    $pot_mean_err = $pot_mean_err; 
    print OUTFILE "\nFirst half minus second half:\n";
    print OUTFILE "    Vdw        El       Total     Potential\n";
    printf OUTFILE " %9.2f %9.2f %9.2f %9.2f\n", $vdw_mean_err, $el_mean_err, $tot_mean_err, $pot_mean_err;
}
else {
    $vdw_mean_err = $vdw_mean_err/$n_means;
    $el_mean_err = $el_mean_err/$n_means; 
    $tot_mean_err = $tot_mean_err/$n_means; 
    $pot_mean_err = $pot_mean_err/$n_means; 
    print OUTFILE "\nCalculated average deviation from mean:\n";
    print OUTFILE "    Vdw        El       Total     Potential\n";
    printf OUTFILE " %9.2f %9.2f %9.2f %9.2f\n", $vdw_mean_err, $el_mean_err, $tot_mean_err, $pot_mean_err;
}

#TODO put above in 'sub avg_calc'
#TODO: add skip function, i.e. skip ## of steps
close(DATFILE);
close(OUTFILE);
close(PLOTFILE);

#--------------------------------------------------------------------
# Finally plot
#--------------------------------------------------------------------
# send data to gnuplot
#open ( GNUPLOT, "|$GNUPlot");
if (!defined(${opt_p})) {
    if (defined(${opt_w})) {$wait=$opt_w;}
    else {$wait=25;}
    open ( GNUPLOT, "|gnuplot");
    print GNUPLOT << "gnuplot_Commands"; #add gnuplot commands below
plot "prot.plot.txt" using 3:1 title "Lennard-Jones" with lines, "prot.plot.txt" using 3:2 title "electrostatic" with lines
pause $wait
gnuplot_Commands
#To print file:
#set xlabel "time (ps)" 
#set ylabel "energy (kcal/mol)" 
#set terminal postscript enhance color "Times-Roman" 14 
#set output "file.ps" 
#replot

close(GNUPLOT);
}

#--------------------------------------------------------------------
#Show result in std-out
#--------------------------------------------------------------------
#system("less prot.resultat.txt");

#--------------------------------------------------------------------
#Clean up temporary files
#--------------------------------------------------------------------
#system("rm -f prot.plot.txt");

#--------------------------------------------------------------------
#--------------------------------------------------------------------
# Subroutines
#--------------------------------------------------------------------
#--------------------------------------------------------------------

    sub extr_qdyn
{
#    my $found;
    do{ 
	$_ =  <LOGFILE>;
	($found) = /qdyn version\s+([\d\.]+)/i;
    } until ((eof) || ($found >= 5.0));
    $version = $found;

    if(!defined($version) || $version < 5.0) 	   #old type of log file
    {
	print "Not a proper logfile!\n";
	exit;
    }
    else #correct type of log file
    {
	if(!defined($opt_t)) {
	    $extrsub = 'extr_total';
	}
	else {
	    $extrsub = 'extr_qsurr';
	}
    }
    
    #first figure out stepsize and output interval
    while(($_ =  <LOGFILE>) && ($. < 40)) 
    {
	if(($found) = /Stepsize\s+\(fs\)\s+=\s+([\d\.]+)/) 
	{
	    $step = $found;
	}
	elsif(($found) = /Energy summary[\s\w-]+=\s+(\d+)/)
	{
	    $freq = $found;
	}
    }
    if($freq > 0) 
    {
	$freq = .001 * $freq;
    }
    else
    {
	seek(LOGFILE, 0, 0); #rewind if no time found
	$freq = 1;
	print STDERR "Warning: stepsize or output cycle not found, now just counting.\n";
    }
    &$extrsub;
}

#--------------------------------------------------------------------
#Different extractions can be made by adding subs below
#--------------------------------------------------------------------

sub extr_qsurr
{
    my $time = 1;
    while($_ = <LOGFILE>) 
    {
	if(($eel, $evdw) = /$match_qsurr/) {    
	    print  DATFILE $evdw . " " . $eel ." " .  $time*$freq . "\n";
	    $time++;
	}			
    }
}

sub extr_total
{
    my $time = 1;
    while($_ = <LOGFILE>) 
    {
	if (/^SUM/) {($total, $potential)= /^SUM\s+(-?[\d\.]+\s+-?[\d\.]+)/;}
	elsif(($eel, $evdw) = /$match_qsurr/) {  
	    print  DATFILE $evdw . " " . $eel . " " . $time*$freq . " " . $total . " " . $potential . "\n";
	    $time++;
	}  
    }	
}


