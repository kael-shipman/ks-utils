#!/usr/bin/env php
<?php

echo "\n\nScanning current directory for jpgs with names that start with timestamps...";

$dir = new DirectoryIterator('.');

$fill = 0;
$data = [];
foreach($dir as $f) {
    if ($f->isFile()) {
        if (strtolower($f->getExtension()) === 'jpg') {
            if (preg_match('/^[0-9:.-]+/', $f->getFilename(), $date)) {
                try {
                    // Split the datetime into pieces
                    $datePieces = preg_split("/[:.-]/", trim($date[0], ":.-"));

                    // Set defaults and standardize
                    for ($i = 0; $i < count($datePieces); $i++) {
                        if (((int)$datePieces[$i]) === 0) {
                            if ($i === 0) {
                                $datePieces[$i] = "1970";
                            } elseif ($i === 1 || $i === 2) {
                                $datePieces[$i] = "01";
                            }
                        }

                        // Pad, if necessary
                        $datePieces[$i] = str_pad(
                            $datePieces[$i],
                            $i === 0 ? 4 : 2,
                            "0",
                            STR_PAD_LEFT
                        );
                    }

                    // Add time if not present
                    for ($i = 3; $i < 6; $i++) {
                        if (!isset($datePieces[$i])) {
                            $datePieces[$i] = "00";
                        }
                    }

                    // Parse into official datetime
                    $date = DateTime::createFromFormat('Y.m.d.H.i.s', implode(".", $datePieces));
                } catch (\Exception $e) {
                    echo "\nError parsing date for file {$f->getFilename()}: {$e->getMessage()}";
                    continue;
                }

                $data[] = [$f->getPathname(), $date];
                if (strlen($f->getPathname()) > $fill) {
                    $fill = strlen($f->getPathname());
                }
            }
        }
    }
}

if (count($data) === 0) {
    echo "\nNothing found!";
} else {
    echo "\n".count($data)." row(s) found. Processing...\n";
    foreach ($data as $row) {
        list($fullpath, $date) = $row;
        $f = "$fullpath:";
        for ($n = $fill+4-strlen($f); $n > 0; $n--) {
            $f .= " ";
        }
        $timestamp = $date->format("Y:m:d H:i:s")."-05:00";
        echo "\n  $f Setting date to ".$timestamp;

        $cmd = "/usr/bin/exiftool -datetimeoriginal='$timestamp' -createdate='$timestamp' '$fullpath'";
        $output = [];
        exec($cmd, $output, $return);
        if ($return > 0) {
            echo " -- ERROR!";
            echo "\n    ".implode("\n  ", $output);
        } else {
            echo " -- success";
        }
    }
}

echo "\n\nDone.\n";

