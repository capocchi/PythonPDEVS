#!/bin/bash

# Script to generate all simulation results in a single folder
# to allow much easier rerunning and updating of plots

export repetitions=1

# Folders are created for all result files and are named
# according to the mindmap

function seq_activity_synthetic {
    #### Synthetic tests for sequential activity
    echo "Running Sequential Activity Synthetic"

    ### Run the simulations
    python seq_activity_synthetic/timer.py $repetitions

    ### Plot the results
    gnuplot seq_activity_synthetic/plot
}

function seq_activity_firespread {
    #### Firespread tests for sequential activity
    echo "Running Sequential Activity Firespread"

    ### Run the simulations
    # Force a higher number of repetions due to high jitter
    python seq_activity_firespread/timer.py 50

    ### Plot the results
    gnuplot seq_activity_firespread/plot
}

function seq_devstone {
    #### DEVStone benchmarks
    echo "Running Sequential DEVStone"

    ### Run the simulations
    pypy-c2.0 seq_devstone/timer.py $repetitions

    ### Plot the results
    gnuplot seq_devstone/plot
}

function dist_activity_synthetic {
    #### Synthetic tests for sequential activity
    echo "Running Distributed Activity Synthetic"

    ### Run the simulations
    python dist_activity_synthetic/timer.py $repetitions

    ### Plot the results
    gnuplot dist_activity_synthetic/plot
}

function dist_activity_citylayout {
    #### Firespread tests for sequential activity
    echo "Running Distributed Activity Citylayout"

    ### Run the simulations
    python dist_activity_citylayout/timer.py $repetitions

    ### Plot the results
    gnuplot dist_activity_citylayout/plot
}

function dist_phold {
    #### PHOLD benchmark
    echo "Running Distributed PHOLD"

    ### Run the simulations
    python dist_phold/timer.py $repetitions

    ### Plot the results
    gnuplot dist_phold/plot
}

function seq_poly {
    #### PHOLD benchmark
    echo "Running Sequential Polymorphic Scheduler"

    ### Run the simulations
    python seq_poly/timer.py $repetitions

    ### Plot the results
    gnuplot seq_poly/plot
}

if [ $# -eq 0 ] ; then
    echo "Run all benchmarks"
    seq_activity_synthetic
    seq_activity_firespread
    seq_devstone
    seq_poly
    dist_activity_synthetic
    dist_activity_citylayout
    dist_phold
elif [ $1 == "seq" ] ; then
    seq_activity_synthetic
    seq_activity_firespread
    seq_devstone
    seq_poly
elif [ $1 == "dist" ] ; then
    dist_activity_synthetic
    dist_activity_citylayout
    dist_phold
elif [ $1 == "seq_activity_synthetic" ] ; then
    seq_activity_synthetic
elif [ $1 == "seq_activity_firespread" ] ; then
    seq_activity_firespread
elif [ $1 == "seq_devstone" ] ; then
    seq_devstone
elif [ $1 == "dist_activity_synthetic" ] ; then
    dist_activity_synthetic
elif [ $1 == "dist_activity_citylayout" ] ; then
    dist_activity_citylayout
elif [ $1 == "dist_phold" ] ; then
    dist_phold
elif [ $1 == "seq_poly" ] ; then
    seq_poly
else
    echo "Unknown benchmark $1"
fi

# Remove the activity log if it is present
(rm activity-log 2>&1) >> /dev/null
