use pdq;

$arrivRate = 0.010;
$servTime  = 1.0;

for ($i = 1; $i <= 10; $i++) {

  pdq::Init("Open Network with M/M/1");
  pdq::CreateOpen("Work", $arrivRate + ($i * 0.090));
  pdq::CreateNode("Server", $pdq::CEN, $pdq::FCFS);  
  pdq::SetDemand("Server", "Work", $servTime);

  pdq::SetWUnit("Cust");
  pdq::SetTUnit("Secs");

  pdq::Solve($pdq::CANON);

  pdq::Report();
}