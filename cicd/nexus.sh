#!/bin/bash
# Update system
yum update -y

# Install Java
yum install java -y

# Go to /opt directory
cd /opt

# Download Nexus tar file
wget https://download.sonatype.com/nexus/3/nexus-3.83.1-03-linux-x86_64.tar.gz

# Extract Nexus
tar -xvzf nexus-3.83.1-03-linux-x86_64.tar.gz

# Rename extracted folder
mv nexus-3.83.1-03 nexus

# Create nexus user
adduser nexus

# Set password for nexus user
echo "nexus:nexus123" | chpasswd

# Allow nexus user to run sudo without password
echo "nexus ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/nexus
chmod 440 /etc/sudoers.d/nexus

# Change ownership of Nexus and sonatype-work
chown -R nexus:nexus /opt/nexus
chown -R nexus:nexus /opt/sonatype-work

# Create nexus.rc file first, then add run_as_user
touch /opt/nexus/bin/nexus.rc
echo 'run_as_user="nexus"' > /opt/nexus/bin/nexus.rc
chown nexus:nexus /opt/nexus/bin/nexus.rc

# Create systemd service file
cat <<EOT > /etc/systemd/system/nexus.service
[Unit]
Description=nexus service
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
ExecStart=/opt/nexus/bin/nexus start
ExecStop=/opt/nexus/bin/nexus stop
User=nexus
Restart=on-abort
TimeoutSec=600

[Install]
WantedBy=multi-user.target
EOT

# Reload systemd, enable and start Nexus service
systemctl daemon-reload
systemctl enable nexus.service
systemctl start nexus.service
