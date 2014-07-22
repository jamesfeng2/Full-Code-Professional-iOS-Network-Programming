<?php

	require_once("./apns.php");
	require_once("./Utils.php");
	
	// create link to database
	$host = "db.yourdomain.com";
	$db = "databaseName";
	$dbuser = "username";
	$dbpass = "password";
	
	$now = date("Y-m-d H:i:s");
	
	$dbConnection = mysql_connect($host, $dbuser, $dbpass);
	if ($dbConnection) {
		mysql_select_db($db, $dbConnection);
	} else {
		// return error status code
		echo "Error connecting to the database.";
		return;
	}
	
	// get request parameter values
	$userId = $_REQUEST['userid'];
	$contactEmail = $_REQUEST['contact'];
	$message = $_REQUEST['message'];
	$badge = $_REQUEST['badge'];
	$sound = $_REQUEST['sound'];
	
	// clean up the action value
	$action = $_REQUEST['action'];
	$action = (!empty($action)) ? $action : "View";
	
	// get token(s) for user
	$sql = "SELECT token 
			FROM user_tokens 
			WHERE userid='".$userId."';";
	$query = mysql_query($sql, $dbConnection);
	
	// send push to ALL devices that belong to user
	while ($row = mysql_fetch_array($query)) {
		// create the payload
		$alert['body'] = $message;
		$alert['action-loc-key'] = $action;
		
		$aps['alert'] = $alert;
		
		// add sound
		if (!empty($sound)) {
			$aps['sound'] = $sound;
		}
		
		// add badge
		if (!empty($badge)) {
			$aps['badge'] = intval($badge);
		}
		
		$payload['aps'] = $aps;
		
		// add custom namespace fields
		$payload['emailAddress'] = $contactEmail;
		
		// connect to apns and send push
		sendPushNotification ($row['token'], json_encode($payload));
	}
	
	// close the database connection
	mysql_close($dbConnection);

?>