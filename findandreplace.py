import paramiko
import re
import time

# create an SSH client
ssh = paramiko.SSHClient()

# add the remote server's host key to the local host key database
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())

# read the private key file
key = paramiko.RSAKey.from_private_key_file('dg_ec2lab_keys.pem')

# connect to the remote server
ssh.connect(
    hostname='54.226.201.30',
    port=22,
    username='ec2-user',
    pkey=key
)

print ("Hi from remote server!")

# open the remote file in read mode
sftp = ssh.open_sftp()
with sftp.open('/usr/share/nginx/html/index.html', 'r') as file:
    # read the file contents
    text = file.read().decode('utf-8')

print("Printing HTML content!")
print(text)

channel = ssh.invoke_shell()
channel.send('sudo su \n')
while not channel.recv_ready():
    time.sleep(1)
print (channel.recv(1024))

channel.send("sed -i 's/LABORATORY Machines!!/LABORATORY PRO/' /usr/share/nginx/html/index.html \n")
while not channel.recv_ready():
    time.sleep(1)
print (channel.recv(1024))

# close the SSH connection
ssh.close()
