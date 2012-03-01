<?PHP

/* 


   The purpose of this script is to take a file from cc_files table, and insert it into
   the schedule table. DB columns at the time of writing are
 
 starts | ends | file_id | clip_length | fade_in | fade_out | cue_in | cue_out | media_item_played | instance_id
 
 an example of data in this row is:
 "9" | "2012-02-29 17:10:00" | "2012-02-29 17:15:05.037166" | 1 | "00:05:05.037166" | "00:00:00" | "00:00:00" | "00:00:00" | "00:05:05.037166" | FALSE | 5

*/

function query($conn, $query){
    $result = pg_query($conn, $query);
    if (!$result) {
        echo "Error executing query $query.\n";
        exit(1);
    }
    
    return $result;
}

function getFileFromCcFiles($conn){
    $query = "SELECT * from cc_files LIMIT 1";
    
    $result = query($conn, $query);
    
    $file = null;
    while ($row = pg_fetch_array($result)) {
        $file = $row;
    }
    
    if (is_null($file)){
        echo "Library is empty. Could not choose random file.";
        exit(1);
    }
    
    return $file;
}

function insertIntoCcShow($conn){
    /* Step 1:
     * Create a show
     *  */

    $query = "INSERT INTO cc_show (name, url, genre, description, color, background_color) VALUES ('test', '', '', '', '', '')";
    echo $query.PHP_EOL;
    $result = query($conn, $query);

    $query = "SELECT currval('cc_show_id_seq');";
    $result = pg_query($conn, $query);
    if (!$result) {
      echo "Error executing query $query.\n";
      exit(1);
    }

    while ($row = pg_fetch_array($result)) {
      $show_id = $row["currval"];
    }
    
    return $show_id;
}

function insertIntoCcShowInstances($conn, $show_id, $starts, $ends, $file){
    /* Step 2:
     * Create a show instance.
     * Column values:
     * starts | ends | show_id | record | rebroadcast | instance_id | file_id | time_filled | last_scheduled | modified_instance
     *  */
     
    $nowDateTime = new DateTime("now", new DateTimeZone("UTC"));

    $now = $nowDateTime->format("Y-m-d H:i:s");


    $columns = "(starts, ends, show_id, record, rebroadcast, instance_id, file_id, time_filled, last_scheduled, modified_instance)";
    $values = "('$starts', '$ends', $show_id, 0, 0, NULL, NULL, '$file[length]', '$now', 'f')";
    $query = "INSERT INTO cc_show_instances $columns values $values ";
    echo $query.PHP_EOL;
     
    $result = query($conn, $query);

    $query = "SELECT currval('cc_show_instances_id_seq');";
    $result = pg_query($conn, $query);
    if (!$result) {
      echo "Error executing query $query.\n";
      exit(1);
    }

    while ($row = pg_fetch_array($result)) {
      $show_instance_id = $row["currval"];
    }
    
    return $show_instance_id;
}

/*
 * id | starts | ends | file_id | clip_length| fade_in | fade_out | cue_in | cue_out | media_item_played | instance_id
 * 1 | 2012-02-29 23:25:00 | 2012-02-29 23:30:05.037166 | 1 | 00:05:05.037166 | 00:00:00 | 00:00:00 | 00:00:00 | 00:05:05.037166 | f | 5
 */
function insertIntoCcSchedule($conn, $file, $show_instance_id, $starts, $ends){
    $columns = "(starts, ends, file_id, clip_length, fade_in, fade_out, cue_in, cue_out, media_item_played, instance_id)";
    $values = "('$starts', '$ends', $file[id], '$file[length]', '00:00:00', '00:00:00', '00:00:00', '$file[length]', 'f', $show_instance_id)";
    $query = "INSERT INTO cc_schedule $columns VALUES $values";
    echo $query.PHP_EOL;
    
    $result = query($conn, $query);
}

$conn = pg_connect("host=localhost port=5432 dbname=airtime user=airtime password=airtime");
if (!$conn) {
    echo "Couldn't connect to Airtime DB.\n";
    exit(1);
}

if (count($argv) > 1){
    if ($argv[1] == "--clean"){    
        $tables = array("cc_schedule", "cc_show_instances", "cc_show");
        
        foreach($tables as $table){
            $query = "DELETE FROM $table";
            echo $query.PHP_EOL;
            query($conn, $query);
        }
        
        exit(0);
    } else { 
        $str = <<<EOD
This script schedules a file to play 15 seconds in the future. It 
modifies the database tables cc_schedule, cc_show_instances and cc_show.
You can clean up these tables using the --clean option.
EOD;
        echo $str.PHP_EOL;
        exit(0);
    }
}

$startDateTime = new DateTime("now + 15sec", new DateTimeZone("UTC"));
$endDateTime = new DateTime("now + 1min 15sec", new DateTimeZone("UTC"));
$starts = $startDateTime->format("Y-m-d H:i:s");
$ends = $endDateTime->format("Y-m-d H:i:s");

$file = getFileFromCcFiles($conn); 
$show_id = insertIntoCcShow($conn);
$show_instance_id = insertIntoCcShowInstances($conn, $show_id, $starts, $ends, $file);
insertIntoCcSchedule($conn, $file, $show_instance_id, $starts, $ends);
