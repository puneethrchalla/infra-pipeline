#!/bin/bash
yum install -y git
yum install jq -y
cd /tmp
BRANCH=""

# Setup git branch to pull from (prod=master branch, nonprod=nonprod branch)
if [[ ${env} == "prod" ]]; then
    BRANCH="master"
else
    BRANCH=${env}
fi

# Download vault key, download the git key from vault, then download git config repo
aws s3 cp s3://lambda-python-script-bucket/secretsmgmt/vault-keys.json vault-keys.json
export VAULT_TOKN=$(cat vault-keys.json  | jq -r .root_token)
export VAULT_ADDR="http://${vault_ip}:${vault_port}/"
/usr/local/bin/vault login $VAULT_TOKN
/usr/local/bin/vault read --field value secret/codecommit-key > ~/.ssh/codecommit.pem
chmod 600 ~/.ssh/codecommit.pem
export GIT_ID=$(/usr/local/bin/vault read --field value secret/codecommit-user)
GIT_SSH_COMMAND='ssh -o "StrictHostKeyChecking no" -i ~/.ssh/codecommit.pem' git clone -b $BRANCH ssh://$GIT_ID@git-codecommit.us-east-1.amazonaws.com/v1/repos/deploy-artifacts/

# Mount EBS volume
mkfs.xfs /dev/nvme1n1
mkdir /storage
echo "/dev/nvme1n1 /storage           xfs    defaults,noatime  0   2" >> /etc/fstab
mount /storage

# Copy the appropriate config dir to root
sudo cp -rf deploy-artifacts/static_cluster/* /

# Setup required directories
sudo mkdir -m 777 /var/lib/singularity
sudo mkdir -m 777 /var/lib/singularity/tasks
sudo mkdir -m 777 /var/lib/singularity/cleanup
sudo mkdir -m 777 /var/lib/singularity/metadata
sudo mkdir -m 777 /var/lib/singularity/logwatcher
sudo mkdir /etc/mesos-slave/attributes

# Setup mesos based on server role
sudo echo "static" > /etc/mesos-slave/attributes/nodetype #app/static

# Setup zookeeper based on instance number
echo ${count} | sed -e "s/“|\"//g" > /var/lib/zookeeper/myid # change based on static cluster node (1|2|3)
sudo chown -R zookeeper:zookeeper /var/lib/zookeeper

# Set service scripts to executable
sudo chmod 755 /etc/init.d/singularity*

# Enable services at boot
sudo systemctl daemon-reload
sudo systemctl enable zookeeper
sudo systemctl enable singularity
sudo systemctl enable singularity-s3-uploader
sudo systemctl enable singularity-s3-downloader

# Stop/start services
sudo systemctl stop zookeeper
sudo systemctl start zookeeper
sudo systemctl stop singularity
sudo systemctl start singularity
sudo systemctl stop singularity-s3-uploader
sudo systemctl start singularity-s3-uploader
sudo systemctl stop singularity-s3-downloader
sudo systemctl start singularity-s3-downloader
