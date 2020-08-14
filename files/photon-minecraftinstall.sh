#!/bin/bash -eux

##
## Retrieve Variables
##
    MINECRAFT_VERSION=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep "guestinfo.minecraft.version") 
    MINECRAFT_SERVERPORT=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep "guestinfo.minecraft.serverport")
    MINECRAFT_ENABLERCON=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep "guestinfo.minecraft.enablercon")
    MINECRAFT_RCONPORT=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep "guestinfo.minecraft.rconport")
    MINECRAFT_RCONPASSWORD=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep "guestinfo.minecraft.rconpassword")

    VERSION=$(echo "${MINECRAFT_VERSION}" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')
    SERVERPORT=$(echo "${MINECRAFT_SERVERPORT}" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')
    RCONPORT=$(echo "${MINECRAFT_RCONPORT}" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')
    RCONPASSWORD=$(echo "${MINECRAFT_RCONPASSWORD}" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')

    ENABLERCON==$(echo "${MINECRAFT_ENABLERCON}" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')
    ENABLERCON=$(echo $ENABLERCON | sed 's/=//g')
    ENABLERCON=${ENABLERCON}

##
## Download Latest Minecraft Server
##

echo '> Download Latest Minecraft Server version'
#chmod +x /opt/Minecraft/scripts/Get-MinecraftServer.ps1
#chmod +x /opt/Minecraft/scripts/Upgrade-MinecraftService.ps1
chmod -vR +x /opt/Minecraft/scripts/
pwsh -noprofile -command "/opt/Minecraft/scripts/Get-MinecraftServer.ps1 -MinecraftVersion ${VERSION}"

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
sed -i "s/enable-rcon=false/enable-rcon=${ENABLERCON}/g" /opt/Minecraft/bin/server.properties
sed -i "s/rcon.password=/rcon.password=${RCONPASSWORD}/g" /opt/Minecraft/bin/server.properties
sed -i "s/rcon.port=25575/rcon.port=${RCONPORT}/g" /opt/Minecraft/bin/server.properties
sed -i "s/server-port=25565/server-port=${SERVERPORT}/g" /opt/Minecraft/bin/server.properties

##
## Minecraft Firewall Configuration
##

echo '> Configure Minecraft Firewall Rules'
iptables -A INPUT -p tcp --dport ${SERVERPORT} -j ACCEPT
iptables -A INPUT -p tcp --dport ${RCONPORT} -j ACCEPT
iptables-save > /etc/systemd/scripts/ip4save

##
## Modify Minecraft Service file with correct rcon port and password
##

sed -i "s/RCONPORT/${RCONPORT}/g" /etc/systemd/system/minecraft.service
sed -i "s/RCONPASSWORD/${RCONPASSWORD}/g" /etc/systemd/system/minecraft.service

##
## Reload systemctl daemon to record changes to the minecraft service file
##

systemctl daemon-reload

##
## Minecraft folder permissions changes
##

echo '> Setting Minecraft Admins group to Owner of Opt folder'
chown -v root:minecraft-admins /opt/
chown -vR minecraft:minecraft-admins /opt/Minecraft


echo '> Setting execute permissions on server.jar'
chmod -vR 755 /opt/Minecraft

##
## Start Minecraft Server Service
##

systemctl enable minecraft.service
systemctl start minecraft.service

echo '> Done'
