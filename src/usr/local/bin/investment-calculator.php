#!/usr/local/bin/php

<?php

// ------ vvvvvv Fill in these numbers ---------

$dob = 1986;
$retirement_age = 70;
$apy = .06;
$initial_bal = 5000;
$monthly_contribution = 458;

// ------ ^^^^^^^ -------------------------------


function calculate_investment($dob, $retirement_age, $apy, $starting_age=null, $initial_bal=0, $monthly_contribution=0) {
  if ($starting_age === null) $starting_age = date('Y') - $dob;
  $current_year = date('Y');
  $current_month = date('m');
  $retirement_year = $dob+$retirement_age;
  $years_accumulated = $retirement_year - $current_year;
  $months_accumulated = $years_accumulated*12;

  $bal = $initial_bal;
  $total_interest = 0;
  $total_investment = 0;
  for ($i=$current_month; $i <= $months_accumulated;$i++) {
      $bal += $monthly_contribution;
      $total_investment += $monthly_contribution;
      if ($i%12 == 0) {
          $interest_payment = $bal*$apy;
          $bal += $interest_payment;
          $total_interest += $interest_payment;
      }
  }

  return array(
    'initial_bal' => $initial_bal,
    'apy' => $apy,
    'monthly_contribution' => $monthly_contribution,
    'retirement_age' => $retirement_age,
    'ending_bal' => round($bal,2),
    'total_investment' => round($total_investment,2),
    'total_interest' => round($total_interest,2)
  );
}

function output_plain_text($info) {
  echo "If you had \$$info[initial_bal] in a mutual fund today earning ".($info['apy']*100)."% annually with monthly contributions of \$$info[monthly_contribution], this is what your finances would look like by age $info[retirement_age]:

Balance at retirement: \$$info[ending_bal]
Total Investment at retirement: \$$info[total_investment]
Total Interest Accumulated by retirement: \$$info[total_interest]";

  echo "\n\n";
}

output_plain_text(calculate_investment($dob, $retirement_age, $apy, null, $initial_bal, $monthly_contribution));

?>
