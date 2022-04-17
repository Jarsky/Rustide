================================================
Script Name: Rustide
Version: 1.7
Publisher: Jarsky
Last Updated: 01.01.2022
================================================


This script will maintain a Rust Experimental server with Oxide2 Mod by allowing the
server to update automatically when the script is run. 

It will check and update both Rust Experimental & Oxide 2, and start the server automatically
at the end of the script. 

Currently updates are pushed out by Facepunch Studios approximately 5pm EDT every Thursday. 

Features:

- Download + Update Rust/Oxide
- Auto Start Rustide (optional)
- Create server backups
- Remove old backups

Usage: 

- Check the SET parameters at the start of the Rustide.bat file to customise your server.
	If backup is enabled "maxbackups" is how many backups it will keep in the folder. 
	The "backuploc" option is for backup location, you can change it to something like C:\RustBackup if you want or leave it as default
	for the Rustide folder.
	****MULTIPLE SERVER BACKUPS**** 
	If you just want to use this script for update+backup, then just change "autostart" to no
- Just run Rustide.bat when you're ready. 
- Want to run multiple servers? Just make multiple Rustide folders with different names (for seperate installs) or copy the Rustide.bat 
  file and change "ident" to something meaningful for each server.

Already have an Oxide modded server? 

- Run this script once then quit the server. 
- Copy configuration files from your current server. Folders to copy are:
	\<rust>\RustDedicated_Data\Managed
	\<rust>\server\my_server_identity

Known Issues:
- The RAW GitHub server occasionally gives a 503 error, because their proxies are lame. The script will keep retrying
- There are no checks for the last update, so it will update your Rust+Oxide every time it restarts. 
- There are no frequency checks for the backup, so it will make a backup every time you restart. 


CHANGELOG:

UPDATE v.1.7
- Updated scripts for uMod & Newer Linux versions -- tested on Ubuntu 21.04 LTS

UPDATE v.1.4
- Added script for Linux support -- tested on Ubuntu

UPDATE v.1.3
- Fixed backup naming convention for non English locales

UPDATE v.1.2
- Added in support for server details on server listing

UPDATE v.1.1
- Fixed bug with autorestart
- Removed Eternals Rust Restarter

UPDATE v.1.0.8
- Adjusted backup for new backup folder

UPDATE v.1.0.7
- Changes to loop when quit/crashes
- Fixed backup prompting if File or Directory

UPDATE v.1.0.6
- Added option to let server restart itself if closed
- Added missing -autoupdate flag

UPDATE v.1.0.5
- Added additional checks for trimming backups in case someone changes path to something stupid, or does have multiple servers backing up in the same folder. 

UPDATE v.1.0.4
- Added check for running instance of RustDedicated server, so additional servers do not try and update if it is running. (in case of a single install with multiple launch instances)
- Added ability to disable Auto Update completely. 
- Added ability to force updates (useful if running completely seperate installs)

UPDATE v.1.0.3
- Changed backup naming convention
- Added backup file trim (will only keep X number of backups)

