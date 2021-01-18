#!/usr/local/bin/php
<?php

echo "\n\nWelcome to Fototool\n";
require __DIR__.'/../lib/fototools.lib.php';

$options = '';
$longopts = array();
$options .= 't:'; // Tool
$options .= 'n:'; // Photographer's name
$options .= 'd:'; // Directory (source)
$longopts[] = 'targ:'; // Target dir

$opts = getopt($options,$longopts);

if (!$opts || count($opts) == 0) die_help();

if (strtolower($opts['t']) == 'datestamp') {
  $photographer = isset($opts['n']) ? $opts['n'] : false;
  $dir = $opts['d'];

  if (!is_dir($dir)) die_help();
  //$photographer = str_replace(' ','_',$photographer);

  echo "\nRenaming files with datestamp and photographer name...";
  recursively_datestamp_files($dir,$photographer);
} elseif (strtolower($opts['t'] == 'separate_dated')) {
  $dir = $opts['d'];
  if (!is_dir($dir)) die_help();
  $targ = isset($opts['targ']) ? $opts['targ'] : "$dir/tmp";

  if (!is_dir($targ)) mkdir($targ, 0775, true);

  echo "\nSeparating files by date...";
  recursively_separate_dated($dir,$targ);
}

echo "done.\n\n";

echo "Thanks!\n";


?>

