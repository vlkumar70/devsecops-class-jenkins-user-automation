# devsecops-class-jenkins-user-automation

## Pre requisites
- you need keypair, security group
- security group should have 22, 8080 ports open
- Spin up Ubuntu 22.04 instance in public subnet
- Make sure you login to the instance

## Jenkins installation scripts
```
sudo apt update -y

sudo apt install openjdk-11-jdk -y

java --version

curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt-get update -y

sudo apt-get install jenkins -y
```

## To check the status of jenkins

```
sudo systemctl start jenkins
sudo systemctl status jenkins
sudo systemctl stop jenkins
```


### Docker installation steps
- Ref : https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-22-04

```
sudo apt update -y

sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update -y

apt-cache policy docker-ce

sudo apt install docker-ce -y

sudo systemctl status docker

```
Note: If you see below error
```
ERROR: permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Get "http://%2Fvar%2Frun%2Fdocker.sock/_ping": dial unix /var/run/docker.sock: connect: permission denied
```

Please execute below steps on ubuntu instance

```
ls -al /var/run/docker.sock 
sudo chmod 777 /var/run/docker.sock
ls -al /var/run/docker.sock 

``
