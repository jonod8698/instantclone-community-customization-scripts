@echo off

echo Adapted from Arthur Cheng with some additions + hostname change fix https://blog.skywebster.com/vmware-instant-clone-windows-and-linux-customized-script/
echo run as admin on template VM before running InstantClone_windows.ps1
echo REPLACE Ethernet0 with the name of the network interface name.

set PATH=%PATH%;C:\Program Files\VMware\VMware Tools\
set IP_ADDRESS=
set HOSTNAME=
set HOSTNAME_ORIG=

echo === Start Pre-Freeze ===
 
timeout 3 > nul
 
echo === Disabling Network Ethernet0 interface ... ===
 
ipconfig /release Ethernet0 > nul 2>&1
netsh interface set interface name="Ethernet0" admin=disable
 
timeout 3 > nul
 
echo === End of Pre-Freeze ===
 
timeout 3 > nul
 
echo === Freezing ... ===
 
vmtoolsd.exe --cmd "instantclone.freeze"
 
timeout 3 > nul
 
echo === Start Post-Freeze ===

for /F "Tokens=*" %%I in ('vmtoolsd.exe --cmd "info-get guestinfo.ic.ipaddress"') do set IP_ADDRESS=%%I
for /F "Tokens=*" %%J in ('vmtoolsd.exe --cmd "info-get guestinfo.ic.hostname"') do set HOSTNAME=%%J
for /F "Tokens=*" %%G in ('vmtoolsd.exe --cmd "info-get guestinfo.ic.gateway"') do set GATEWAY=%%G
for /F "Tokens=*" %%D in ('vmtoolsd.exe --cmd "info-get guestinfo.ic.dns"') do set DNS=%%D

for /F "Tokens=*" %%K in ('hostname') do set HOSTNAME_ORIG=%%K

timeout 1 > nul
 
echo === Updating IP Address ... === admin below means administratively down or up
netsh interface set interface name="Ethernet0" admin=enable
netsh interface ipv4 set address name="Ethernet0" static %IP_ADDRESS% 255.255.255.0 %GATEWAY%
netsh interface ip set dns "Ethernet0" static %DNS% > nul 2>&1

timeout 2 > nul
echo %HOSTNAME_ORIG%
echo %HOSTNAME%

echo === Updating Hostname ... ===
wmic computersystem where caption='%HOSTNAME_ORIG%' rename '%HOSTNAME%' > nul 2>&1

timeout 3 > nul
 
echo === End of Post-Freeze ===
 
timeout 3 > nul
 
echo === Reboot Guest ===
shutdown -r -t 1