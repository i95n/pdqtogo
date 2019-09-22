#!/usr/bin/perl

use pdq;

# Globals
$arrivRate = 0.75;
$servTime  = 1.0;

# Initialize PDQ and add a comment about the model
pdq::Init("Open Network with M/M/1");
pdq::SetComment("This is just a very simple example.");

# Define the workload and circuit type
pdq::CreateOpen("Work", $arrivRate);

# Define the queueing center
pdq::CreateNode("Server", $pdq::CEN, $pdq::FCFS);  

# Define service demand due to workload on the queueing center
pdq::SetDemand("Server", "Work", $servTime);

# Change units labels to suit
pdq::SetWUnit("Cust");
pdq::SetTUnit("Secs");

# Solve the model
#  Must use the Canonical method for an open network
pdq::Solve($pdq::CANON);

# Generate a generic performance report
pdq::Report();