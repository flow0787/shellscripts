#FTP SITE TRANSFER SCRIPT#

clear;
BLUE='\033[0;34m'
DARK_RED='\033[1;31m'
NC='\033[0m' 

echo -e "${BLUE}-=====BEGIN FTP SITE TRANSFER=====-${NC}"


if [ ! -d transfer ]; then
	mkdir transfer; cd transfer;
	read -p "FTP user: " ftp_user;
	read -p "FTP pass: " ftp_pass;
	read -p "FTP host: " ftp_host;
	wget -mb --passive-ftp --ftp-user=$ftp_user --ftp-password=$ftp_pass ftp://$ftp_host
else
	echo -e "${DARK_RED}transfer directory already exists:${NC}"
	ls -lah transfer
fi




