CREATE TABLE IF NOT EXISTS `users` (
  `userid` varchar(120) 
  	NOT NULL,
  `datecreated` timestamp 
  	NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`userid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `user_tokens` (
  `userid` varchar(120) NOT NULL,
  `token` varchar(64) NOT NULL,
  `datecreated` timestamp 
  	NOT NULL DEFAULT '0000-00-00 00:00:00',
  `dateremoved` timestamp 
  	NOT NULL DEFAULT '0000-00-00 00:00:00' 
  	COMMENT 'date the feedback service was polled for token',
  PRIMARY KEY (`userid`,`token`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
