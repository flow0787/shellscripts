    read -rp "sFTP user: " ftp_user;
    read -rp "sFTP pass: " ftp_pass;
    read -rp "sFTP host: " ftp_host;
    read -rp "Site path: " old_path;
    read -rp "New site path: " new_path
    lftp -u "$ftp_user","$ftp_pass" -e `mirror "$old_path" "$new_path"` sftp://"$ftp_host":22
