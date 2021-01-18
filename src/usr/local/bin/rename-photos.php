#!/usr/local/bin/php
<?php

$path = $argv[1];
if (!$path) {
    $path = getcwd();
}
$path = rtrim($path, '/');


function say($str="", $newline=true) {
    echo $str;
    if ($newline) echo "\n";
}

function isProcessable($file) {
    $ext = substr($file[1], strrpos($file[1], '.')+1);
    if (in_array(strtolower($ext), ['jpg','nef'])) {
        return true;
    }
    return false;
}

function getXmpFiles($file, $fileset) {
    $period = strrpos($file[1], '.');
    $basename = substr($file[1], 0, $period);
    $ext = substr($file[1], $period);
    $xmpFiles = [];

    foreach($fileset as $f) {
        if (preg_match("/^{$basename}(_[0-9]+)?{$ext}.xmp$/i", $f[1], $matches)) {
            $xmpFiles[] = $matches[0];
        }
    }

    return $xmpFiles;
}

function getDatetime($val, $formats) {
    foreach($formats as $format) {
        $datetime = \DateTime::createFromFormat($format, $val);
        if ($datetime !== false) return $datetime;
    }
    return false;
}

say("

----------------------------------------------------------
##         Rename Photos with Date and Creator          ##
----------------------------------------------------------
");






//echo "\n\nSORRY! This isn't ready for production yet. Currently, it seems to be mixing up\ncertain xmp files.\n\n";
//die();











say("Searching (non-recursively) in directory `$path` for photos with exif data and sidecar files....");

$dir = dir($path);

$datetimeFormats = ['Y:m:d H:i:s'];
$instructions = [];
$creators = [];
$fileset = [];
$usedNames = [];
$curPath = $path;
while ($file = $dir->read()) {
    if (substr($file, 0, 1) == '.') continue;
    $fileset[] = [ $curPath, $file, filemtime("$curPath/$file") ];
}

foreach($fileset as $file) {
    if (!isProcessable($file)) continue;

    // Get XMP file path, if there is one
    $xmpFiles = getXmpFiles($file, $fileset);
    if (count($xmpFiles) > 0) {
        $xmp = $xmpFiles[0];
    } else {
        $xmp = null;
    }

    $creator = null;
    $timestamp = null;

    // If there's an xmp file, try to get creator from it
    if ($xmp) {
        $xml = new DOMDocument();
        $xml->load("$file[0]/$xmp");
        $xml = $xml->getElementsByTagName('creator');
        if ($xml->length > 0) {
            $xml = $xml[0]->getElementsByTagName('li');
            if ($xml->length > 0) {
                $creator = trim($xml[0]->nodeValue);
            }
        }
    }

    // Now get timestamp and possibly creator from exif
    $exif = @exif_read_data("$file[0]/$file[1]", false, true);
    if (!$exif) {
        say("\n\n ERROR: Can't read exif :(. Skipping file `$file[1]`.");
        continue;
    }

    if (array_key_exists("DateTimeOriginal", $exif['EXIF']) && trim($exif['EXIF']['DateTimeOriginal']) != '') {
        $datetime = trim($exif['EXIF']['DateTimeOriginal']);
        do {
            if ($timestamp = getDatetime($datetime, $datetimeFormats)) {
                break;
            }

            echo "\n  Datetime `$datetime` found for photo `$file[1]`, but don't know how to interpret it.";
            echo "\n  Please enter a format string that describes this datetime (e.g., Y:m:d H:i:s)";
            $ans = trim(readline("\n  or enter \"cancel\" to give up: "));
            if (strtolower($ans) === 'cancel') {
                echo "\n\n  Ok, giving up. Moving on to next photo.";
                break;
            } else {
                $datetimeFormats[] = $ans;
            }
        } while (true);

        // TODO: Add more options for datetime field
    }

    if (!$timestamp) {
        say("Couldn't get a timestamp for photo `$file[1]`. Skipping.");
        continue;
    }

    if (!$creator && array_key_exists("IDF0", $exif) && array_key_exists("Artist", $exif['IDF0'])) {
        $creator = trim($exif['IDF0']['Artist']);
        if ($creator === '') {
            $creator = null;
        }
    }

    if (!$creator) {
        say("Couldn't get a creator for photo `$file[1]`. Skipping.");
        continue;
    }

    $targFilename = $timestamp->format('Y.m.d-H.i.s')." - $creator";
    $baseTargFilename = $targFilename;
    for ($i = 1; in_array($targFilename, $usedNames); $i++) {
        $targFilename = "{$baseTargFilename}.".sprintf("%02d", $i);
    }
    $usedNames[] = $targFilename;

    if (!array_key_exists($file[0], $instructions)) $instructions[$file[0]] = [];

    $instructions[$file[0]][] = [
        'file' => $file[1],
        'xmpFiles' => $xmpFiles,
        'targFilename' => $targFilename
    ];
}

if (count($instructions) == 0) {
    say("\nWoops! No valid image files found to rename. Are you sure you gave the right directory?");
} else {
    foreach($instructions as $dir => $sets) {
        $tmpPath = "$dir/tmp";
        mkdir($tmpPath);

        foreach($sets as $set) {
            say("Rename `$set[file]` and ".count($set['xmpFiles'])." accompanying XMP file(s) to `$set[targFilename](.ext)`");

            $basename = substr($set['file'], 0, strrpos($set['file'], '.'));
            $ext = substr($set['file'], strrpos($set['file'], '.'));
            say("  rename(\"$file[0]/$set[file]\", \"$tmpPath/$set[targFilename]$ext\");");
            rename("$file[0]/$set[file]", "$tmpPath/$set[targFilename]$ext");

            foreach ($set['xmpFiles'] as $xmpFile) {
                $targXmp = str_replace($basename, $set["targFilename"], $xmpFile);

                // Replace any references to the original filename with the target filename
                $contents = file_get_contents("$file[0]/$xmpFile");
                $contents = str_replace($set['file'], "$set[targFilename]$ext", $contents);
                file_put_contents("$file[0]/$xmpFile", $contents);

                // Now rename the file
                say("  rename(\"$file[0]/$xmpFile\", \"$tmpPath/$targXmp\");");
                rename("$file[0]/$xmpFile", "$tmpPath/$targXmp");
            }
        }

        exec("mv '$tmpPath/'* '$dir/'");
        exec("rmdir '$tmpPath'");
    }
}

say();

