#!/bin/bash -eux

##
## Download Latest Minecraft Server
##

echo '> Download Latest Minecraft Server version'
chmod +x /opt/Minecraft/scripts/Get-MinecraftServer.ps1
pwsh -noprofile -command '/opt/Minecraft/scripts/Get-MinecraftServer.ps1'

##
## Minecraft Server Initialization
##

echo '> Start Minecraft Server for the first time'
cd /opt/Minecraft/bin/
java -Xmx1536M -Xms512M -jar /opt/Minecraft/bin/server.jar --initSettings

##
## Minecraft Configuration File Edits
##

echo '> Edit EULA file'
sed -i 's/eula=false/eula=true/g' /opt/Minecraft/bin/eula.txt

echo '> Edit server.properties file'
sed -i 's/enable-rcon=false/enable-rcon=true/g' /opt/Minecraft/bin/server.properties
sed -i 's/rcon.password=/rcon.password=D@y1ight/g' /opt/Minecraft/bin/server.properties

##
## Minecraft Firewall Configuration
##

echo '> Configure Minecraft Firewall Rules'
iptables -A INPUT -p tcp --dport 25565 -j ACCEPT
iptables -A INPUT -p tcp --dport 25575 -j ACCEPT
iptables-save > /etc/systemd/scripts/ip4save


##
## Minecraft folder permissions changes
##

echo '> Setting Minecraft Admins group to Owner of Opt folder'
chown -v root:minecraft-admins /opt/
chown -vR minecraft:minecraft-admins /opt/Minecraft


echo '> Setting execute permissions on server.jar'
chmod -vR 755 /opt/Minecraft

echo '> Done'
