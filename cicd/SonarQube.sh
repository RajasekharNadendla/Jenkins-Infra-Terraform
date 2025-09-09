#!/bin/bash

# Simple SonarQube installation script

# Variables
SONAR_VERSION="9.9.3.79811"
SONAR_USER="sonar"
INSTALL_DIR="/opt/sonarqube"
SONAR_URL="https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${SONAR_VERSION}.zip"

# Update system
yum update -y

# Install Java and unzip
yum install -y java-17-amazon-corretto wget unzip

# Create sonar user
useradd -m -s /bin/bash $SONAR_USER

# Download and extract SonarQube
cd /opt
wget $SONAR_URL
unzip sonarqube-${SONAR_VERSION}.zip
mv sonarqube-${SONAR_VERSION} $INSTALL_DIR
rm -f sonarqube-${SONAR_VERSION}.zip

# Set ownership
chown -R $SONAR_USER:$SONAR_USER $INSTALL_DIR

# Create systemd service
cat <<EOF > /etc/systemd/system/sonarqube.service
[Unit]
Description=SonarQube service
After=network.target

[Service]
Type=forking
User=$SONAR_USER
Group=$SONAR_USER
ExecStart=$INSTALL_DIR/bin/linux-x86-64/sonar.sh start
ExecStop=$INSTALL_DIR/bin/linux-x86-64/sonar.sh stop
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Enable and start service
systemctl daemon-reload
systemctl enable sonarqube
systemctl start sonarqube

echo "SonarQube installed successfully!"
echo "Open http://<EC2-PUBLIC-IP>:9000 in your browser"
echo "Default login: admin / admin"
