<?php
	require_once("./Utils.php");

	// typically there would be much more
	// validation done on the request and
	// cleaner database handling
	
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
		sendAPIResponse(500);
		return;
	}
	
	// get the post body
	$userid = $_REQUEST['user'];
	$token = $_REQUEST['token'];
	
	if (empty($userid) || empty($token)) {
		sendAPIResponse(400);
		return;
	}
	
	// determine if user exists
	$sql = "SELECT userid 
			FROM users 
			WHERE userid='".$userid."' LIMIT 1;";
	$query = mysql_query($sql, $dbConnection);
	$userExists = mysql_fetch_row($query);
	
	// add a 'user' record
	if (!$userExists) {
		$sql = "INSERT INTO users (userid, datecreated) 
				VALUES ('".$userid."', '".$now."');";
		if (!mysql_query($sql, $dbConnection)) {
			// return error
			sendAPIResponse(400);
			return;
		}
		
	}
	
	// determine if token already exists
	$sql = "SELECT token 
			FROM user_tokens 
			WHERE userid='".$userid."' 
			  AND token='".$token."' LIMIT 1;";
	$query = mysql_query($sql, $dbConnection);
	$tokenExists = mysql_fetch_row($query);
	
	// add a token for current user
	if (!$tokenExists) {
		
		$sql = "INSERT INTO user_tokens (userid, token, datecreated) 
				VALUES ('".$userid."','".$token."','".$now."');";
		if (!mysql_query($sql, $dbConnection)) {
			// return error
			sendAPIResponse(400);
			return;
		}
	}
	
	// close the database connection
	mysql_close($dbConnection);
	
	// return success
	sendAPIResponse(200);
	 
?>