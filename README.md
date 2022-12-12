[1] // CREATE SSH KEYS IN AWS MANAGEMENT CONSOLE AND PUT PEM IN THE PATH OF THE MAIN.TF TERRAFORM ----------------------
-----------> PUT *.PEM FILE IN THE PATH OF TERRAFROM MAIN.TF

[2] // SETUP AWS CLI -----------------------------------------------

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

[3] // CONFIGURE AWS CLI   ------------------------------------------
aws configure

[4] // INSTALL TERRAFORM  --------------------------------------------
/* UPDATE LINUX FIRST
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common

[5] /* INSTALL TERRAFORM ----------------------------------------------
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg

gpg --no-default-keyring \
    --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    --fingerprint

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update

sudo apt-get install terraform

terraform version

[6] // INIT TERRAFORM ------------------------------------------------------------------------------------------------
terraform init

[7] // PLAN TERRAFORM ------------------------------------------------------------------------------------------------
terraform plan

[8] // APPLY TERRAFORM ------------------------------------------------------------------------------------------------
terraform apply

[9] // CONNECT TO THE INSTANCES  ------------------------------------------------------------------------------------------------
/* \\wsl$  in CMD in WINDOWS to see C: FILES!

******************* ///// IMPORTANT IF UNABLE TO CONNECT VIA SSH ////// *******************

IN AWS ADD 0.0.0.0/0 in VPC > Route tables >>> ROUTES  

DESTINATION: 0.0.0.0/0
TARGET: INTERNET GATEWAY IN USE ---> EJ : igw-0063c1e60a949f2c0

******************* ///// IMPORTANT IF UNABLE TO CONNECT VIA SSH ////// *******************

[10] // SSH TO THE INSTANCES  --------------------
ssh -i "*******.pem" USER-NAME@xxx.xxx.xxx.xxx

The default user name for your EC2 instance is determined by the AMI that was specified when you launched the instance.
The default user names are:
    For Amazon Linux 2 or the Amazon Linux AMI, the user name is ec2-user.
    For a CentOS AMI, the user name is centos or ec2-user.
    For a Debian AMI, the user name is admin.
    For a Fedora AMI, the user name is fedora or ec2-user.
    For a RHEL AMI, the user name is ec2-user or root.
    For a SUSE AMI, the user name is ec2-user or root.
    For an Ubuntu AMI, the user name is ubuntu.
    For an Oracle AMI, the user name is ec2-user.
    For a Bitnami AMI, the user name is bitnami.
    Otherwise, check with the AMI provider.
    
[11] // DESTROY EC2 INSTANCE USED FOR LAB IN TERRAFORM ---------------------------------------------
terraform destroy
