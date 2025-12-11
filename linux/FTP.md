# FTP Server

```bash
sudo apt update
sudo apt install vsftpd

sudo systemctl start vsftpd
sudo systemctl enable vsftpd

sudo cp /etc/vsftpd.conf /etc/vsftpd.conf_default # Backup of FTP conf

```

Update basic FTP configuration:

```conf
local_enable=YES # Enable local user to access FTP
write_enable=YES # Enable local user to perform write command
chroot_local_user=YES
chroot_list_file=/etc/vsftpd.chroot_list
allow_writeable_chroot=YES
user_sub_token=$USER
local_root=/home/$USER/ftp # Set default directory after ftp login
```

```bash
# Create FTP user [optional]
sudo useradd -m ftpharsh
sudo passwd ftpharsh

# Allow ftp traffic
sudo ufw allow 20/tcp
sudo ufw allow 21/tcp

# make home dir for above ftp-user
sudo mkdir /home/ftpharsh/ftp

# configure ownership
sudo chown nobody:nogroup /home/ftpharsh/ftp

# remove the root /ftp writeable permission
sudo chmod a-w /home/ftpharsh/ftp
sudo mkdir /home/ftpharsh/ftp/upload # Create a dir for uploading files. [optional]
sudo chown ftpharsh:ftpharsh /home/ftpharsh/ftp/upload # Allow access for ftp user

# Write a file inside /home/ftpharsh/ftp/upload
echo "FTP Server" | sudo tee /home/ftpharsh/ftp/upload/demo.txt

# Verify the step
sudo cat /home/ftpharsh/ftp/upload/demo.txt

echo "ftpharsh" | sudo tee -a /etc/vsftpd.userlist

# Connect to the ftp server with above user
sudo ftp system_name # Replace with your system_name

# Provide above created username-password
```

```bash
# Get into the ftp server
ftp ftp://username:password@server-ip
```

## How to Change FTP Port in Linux

FTP protocol uses the standard port **21/TCP** as command port.

In order to change Proftpd service default port in Linux, first open Proftpd main configuration file for editing with your favorite text editor by issuing the below command. The opened file has different paths, specific to your own installed Linux distribution.

```bash
vim /etc/proftpd/proftpd.conf
```

In above file, search and comment the line that begins with **Port 21**. Then, under this line, add a new port line with the new port number.

If there is no such line, add line at the top of configuration file.

You can add any TCP non-standard port between 1024 to 65535, with the condition that the new port is not already taken by other application.

```conf
# Port 21
Port 2121
```

After changing port number, restart the `Proftpd` daemon to apply changes and issue `netstat` command to confitm that FTP listens on **2121/TCP** port.

```bash
sudo systemctl restart proftpd
netstat -tlnp | grep ftp
```

Update your linux firewall rules in order to allow inbound traffic on the new FTP port.

Also, check FTP server passive port range and make sure you also update the firewall rules to reflect passive port range.
