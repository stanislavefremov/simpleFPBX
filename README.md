# simpleFPBX
This is a simpe script to install FreePBX on clean CentOS 7 system.
It was written according to official installation instructions on https://wiki.freepbx.org/display/FOP/Installing+FreePBX+14+on+CentOS+7
It could be safely used on fresh installation of CentOS7, no matter where it was implemented - private server, Digital Ocean droplet, Amazon EC2 instance, Google cloud etc.
To run the script you just need to download it and run with superadmin privileges. During the installation it will ask you few times about the installation options - you need to decide if you want to use DAHDI(in case you have PSTN hardare) and/or Google Voice, as long as it will show asterisk installation menu where you can specify some installation settings and choose which plugins should be installed.
