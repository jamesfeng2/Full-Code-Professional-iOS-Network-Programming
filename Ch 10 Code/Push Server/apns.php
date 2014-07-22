<?php
	
	function sendPushNotification ($token, $payload) {
		
		$certificate = "../Path/To/Certificate/AcmeCertKey.pem";
		$passphrase = "YourPassphrase";
		$endpoint = "ssl://gateway.sandbox.push.apple.com:2195" // prod: ssl://gateway.push.apple.com:2195
		
		$context = stream_context_create();
		stream_context_set_option ($context, 
								   'ssl', 
								   'local_cert', 
								   $certificate);
								   
		stream_context_set_option ($context, 
								   'ssl', 
								   'passphrase', 
								   $passphrase);
		
		// connect to APNs server
		$conn = stream_socket_client(
			$endpoint,
			$err,
			$errstr,
			60,
			STREAM_CLIENT_CONNECT | STREAM_CLIENT_PERSISTENT,
			$context
		);
		
		if (!$conn) {
			echo "Connection to APNs Failed...";
			return;
		}
		
		// build the binary
		$message = chr(0) .
				   pack('n', 32) . 
				   pack('H*', $token) .
				   pack('n', strlen($payload)) .
				   $payload;
				   
		// push the notification
		$result = fwrite($conn, $message, strlen($message));
		
		// close the connection to APNs
		fclose($conn);
		
		
		if ($result) {
			echo "Notification sent...";
		} else {
			echo "Error sending notification...";
		}
			
	}

?>