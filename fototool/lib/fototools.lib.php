<?php

function recursively_datestamp_files($dir,$photographer=false) {
    chdir($dir);
    $dir = dir('.');
    while(false !== ($file = $dir->read())) {
        // Bypass dot files
        if (substr($file,0,1) == '.') continue;
        // Recurse into directories
        if (is_dir($file)) recursively_datestamp_files($file);
        else {
            $new_name = create_datestamp_filename($file, $photographer);
            if (!$new_name) continue;
            rename_file_with_xmp($file,$new_name);
        }
    }
    chdir('..');
}

function recursively_separate_dated($dir,$dest) {
    chdir($dir);
    $dir = dir('.');
    while(false !== ($file = $dir->read())) {
        // Bypass dot files
        if (substr($file,0,1) == '.') continue;
        // Recurse into directories
        if (is_dir($file)) recursively_separate_dated($file,$dest);
        else {
            ///////////////// Get Photographer from filename

            if (strpos($file, 'Nathan_Gray')) $photograher = 'Nathan_Gray';
            else $photographer = 'Unknown';

            ////////////////

            $new_name = create_datestamp_filename($file,$photographer);
            if (!$new_name) continue;

            rename_file_with_xmp($file,"$dest/$new_name");
        }
    }
    chdir('..');
}






function die_help() {
    die('Usage:
        '.$argv[0].' -t datestamp -d SOURCE DIR -n PHOTOGRAPHER\'S NAME
        '.$argv[0].' -t separate_dated -d SOURCE DIR -t TARGET DIR'."\n");
}

function is_exifready_file($file) {
    $ext = substr($file, strrpos($file, '.')+1);
    $valid_exts = array('nef'=>true, 'cr2'=>true, 'jpg'=>true, 'jpeg'=>true, 'tif'=>true, 'tiff'=>true, 'mov'=>true);
    return isset($valid_exts[strtolower($ext)]);
}

function get_file_datestamp($file,$format='Y.m.d-H.i.s') {
    // Now try to read exif data
    if (!is_exifready_file($file)) return false;
    try {
        $data = @exif_read_data($file);
        // try a couple different date sources
        if (isset($data['DateTimeOriginal'])) {
            $timestamp = strtotime($data['DateTimeOriginal']);
            $datestamp = date($format, $timestamp);
        } else {
            throw new RuntimeException('No exif DateTimeOriginal information');
        }

        if (!preg_match('/(19[6-9][0-9]|20[0-9]{2})\\.(0[1-9]|1[0-2])\\.([012][1-9]|10|20|30|31)-/', $datestamp)) throw new RuntimeException('Exif data not consistent');

        return $datestamp;
    } catch (Exception $e) {
        echo "\nFile '$file' doesn't have standard EXIF data!";
        return false;
    }
}

function create_datestamp_filename($file,$default_name=false) {
    $datestamp = get_file_datestamp($file);
    if (!$datestamp) return false;

    // Get ext
    $ext = substr($file,strrpos($file,'.')+1);

    // Get name suffix
    $suffix = get_new_suffix($file, $default_name);

    // Make sure there's no overlap
    $tag = '';
    while (file_exists("{$datestamp}_$suffix$tag.$ext")) {
        if ($tag === '') $tag = 1;
        else $tag++;
    }

    $new_name = "{$datestamp}_$suffix$tag.$ext";
    return $new_name;
}

function get_new_suffix($file, $default_name=false) {
    $suffix = false;

    // First, check xmp data
    $xmpdata = get_xmpdata($file);
    var_dump($xmpdata);
    //var_dump((string) $xmpdata->{'rdf:RDF'}->{'rdf:Description'}->{'dc:creator'}->{'rdf:Seq'}->{'rdf:li'});
    die();
    // Have no clue how to deal with namespaces here
    if ($xmpdata) {
    }
    
    // Then try exif
    if (!$suffix && is_exifready_file($file) && $exifdata = @exif_read_data($file)) {
        if ($exifdata['Creator']) $suffix = $exifdata['Creator'];
        elseif ($exifdata['Author']) $suffix = $exifdata['Author'];
    }

    // Then try default photographer name
    if (!$suffix && $default_name) $suffix = $default_name;

    // Else just use the file name
    if (!$suffix) $suffix = substr($file,0,strrpos($file,'.'));

    return $suffix;
}

function get_xmpdata($file) {
    $file_without_ext = substr($file,0, strrpos($file,'.'));
    $xmpsrc = false;
    if (file_exists("$file.xmp")) $xmpsrc = "$file.xmp";
    elseif (file_exists("$file.XMP")) $xmpsrc = "$file.XMP";
    elseif (file_exists("$file_without_ext.xmp")) $xmpsrc = "$file_without_ext.xmp";
    elseif (file_exists("$file_without_ext.XMP")) $xmpsrc = "$file_without_ext.XMP";

    if (!$xmpsrc) return null;

    return simplexml_load_file($xmpsrc, null, 0, 'x', true);
}

function rename_file_with_xmp($file,$new_name) {
    // Try to rename the file
    try {
        rename($file, $new_name);

        // Also rename any sidecar files....
        $count = null;
        while (file_exists(add_number_to_filename($file, $count).'.xmp') || file_exists(add_number_to_filename($file, $count).'.XMP')) {
            // Rename the file
            if (file_exists(add_number_to_filename($file, $count).'.xmp')) rename(add_number_to_filename($file, $count).'.xmp', add_number_to_filename($new_name, $count).'.xmp');
            else rename(add_number_to_filename($file, $count).'.XMP', add_number_to_filename($new_name, $count).'.XMP');

            if ($count === null) $count = 1;
            else $count++;
        }
    } catch (Exception $e) {
        echo "\nCan't rename file: $e";
    }
}

function add_number_to_filename($file, $number=null) {
    if ($number === null) return $file;

    // Otherwise, add number
    $number = sprintf('%02d', $number);
    $parts = explode('.', $file);
    $parts[count($parts)-2] .= "_$number";

    return implode('.',$parts);
}


?>
