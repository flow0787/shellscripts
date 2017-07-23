#FTP SITE TRANSFER SCRIPT#

clear;
echo "=====BEGIN FTP SITE TRANSFER====="


if [ ! -d transfer ]; then
	mkdir transfer; cd transfer;
	read -p "FTP user: " ftp_user;
	read -p "FTP pass: " ftp_pass;
	read -p "FTP host: " ftp_host;
	wget -mb --passive-ftp --ftp-user=$ftp_user --ftp-password=$ftp_pass ftp://$ftp_host
else
	echo "Transfer directory already exists:"
	ls -lah transfer
fi




