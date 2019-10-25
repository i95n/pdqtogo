use pdq;

for ($i = 1; $i <= 10; $i++) {

	$globalRate = 0.1 + (0.03 * $i);

	$idfRate = $globalRate * 0.6; # <--- ratio 4
	$qcRate = $globalRate * 0.16; # <--- ratio 15
	$enrRate = $globalRate * 0.24;# <--- ratio 6

	pdq::Init("1 cluster");

	pdq::CreateOpen("Idfs", $idfRate);
	pdq::CreateOpen("Qcs", $qcRate);
	pdq::CreateOpen("Enr", $enrRate);

	pdq::CreateNode("CPU", $pdq::CEN, $pdq::FCFS);

	pdq::SetDemand("CPU", "Idfs", 2);
	pdq::SetDemand("CPU", "Qcs", 0.6);
	pdq::SetDemand("CPU", "Enr", 3.2);

	pdq::SetWUnit("Op");
	pdq::SetTUnit("Sec");

	pdq::Solve($pdq::CANON);

	pdq::Report();

}