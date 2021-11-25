#!/bin/bash

# global variables
FIRST_RUN=
SECOND_RUN=
PLOT_XMIN=-0.5
PLOT_XMAX=1.5
PLOT_NBINS=1000
PLOT_XTITLE=

function SYNOPSIS(){
    echo "Synopsis: $0"
    echo "Options:"
    echo " --first  :  first file"
    echo " --second :  second file"
    echo " --xmin   : min histogram set to: $PLOT_XMIN"
    echo " --xmax   : max histogram set to: $PLOT_XMAX"
    echo " --nbins  : number of bins: $PLOT_NBINS"
    echo " --xtitle : title"
    return
}

function LOGGER(){
    VERBOSE=$1
    shift 1
    echo `date +"[%Y-%m-%d - %T]" ` ${VERBOSE}: $@
    return
}

function PARSE_OPTIONS(){
    for i in "$@"
    do
	case $i in
	    --first-run=*)
		FIRST_RUN="${i#*=}"
		;;
	    --second-run=*)
		SECOND_RUN="${i#*=}"
		;;
	    --xmin=*)
		PLOT_XMIN="${i#*=}"
		;;
	    --xmax=*)
		PLOT_XMAX="${i#*=}"
		;;
	    --nbins=*)
		PLOT_NBINS="${i#*=}"
		;;
	    --xtitle=*)
		PLOT_XTITLE="${i#*=}"
		;;
	    --help|-h)
		SYNOPSIS
		exit 0
		;;
	    *)
		# unknown option
		;;
	esac
    done
    return
}

function COMPARE_RUNS(){
    if [ "$#" -ne 2 ]; then
	LOGGER FATAL "Wrong number of input arguments"
	exit 1
    fi
    local F1=$1
    local F2=$2
    local TEST_NAMES=$(cat $F1|grep Passed|awk '{print $4}')
    if [ -f results.dat ]; then
	rm results.dat
    fi
    for TEST_NAME in $TEST_NAMES; do
	local T1=$(cat $F1 | grep Passed| grep $TEST_NAME|awk '{print $7}')
	local T2=$(cat $F2 | grep Passed| grep $TEST_NAME|awk '{print $7}')
	if [ ! -z "$T2" ]; then
	    local PULL=$(echo "$T2/$T1" | bc -l)
	    echo $PULL >> results.dat
	fi
    done
    return
}

function PLOT_GNUPLOT(){
    local F=results.gnp
    rm -f $F
    cat <<EOF >> $F
reset
n=${PLOT_NBINS}
max=${PLOT_XMAX}
min=${PLOT_XMIN}
width=(max-min)/n
hist(x,width)=width*floor(x/width)+width/2.0
set term png #output terminal and file
set output "results.png"
set xrange [min:max]
set yrange [0:]
set offset graph 0.05,0.05,0.05,0.0
set xtics min,(max-min)/5,max
set boxwidth width*0.9
set style fill solid 0.5 #fillstyle
set tics out nomirror
set xlabel "$PLOT_XTITLE"
set ylabel "Frequency"
plot "results.dat" u (hist(\$1,width)):(1.0) smooth freq w boxes lc rgb"green" notitle
EOF
    local GNUPLOT=$(which gnuplot)
    if [ -z GNUPLOT ]; then
	LOGGER ERROR "Gnuplot seems to be missing from node"
    else
	rm -f histogram.
	gnuplot $F
	
    fi
    return
}

function main(){
    PARSE_OPTIONS "$@"
    COMPARE_RUNS $FIRST_RUN $SECOND_RUN
    if [ -z "$PLOT_XTITLE" ]; then
	PLOT_XTITLE="$SECOND_RUN / $FIRST_RUN"
    fi
    PLOT_GNUPLOT
    return
}

main "$@"
