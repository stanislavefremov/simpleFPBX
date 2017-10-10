# simpleFPBX
This is a simpe script to install FreePBX on clean CentOS 7 system.
It was written according to official installation instructions on https://wiki.freepbx.org/display/FOP/Installing+FreePBX+14+on+CentOS+7
It could be safely used on fresh installation of CentOS7, no matter where it was implemented - private server, Digital Ocean droplet, Amazon EC2 instance, Google cloud etc.
To run the script you just need to download it and run with superadmin privileges. During the installation it will ask you few times about the installation options - first it will ask you for some option of MySQL/MariaDB installation(please read it at the end of Readme), you need to decide if you want to use DAHDI(in case you have PSTN hardare) and/or Google Voice, as long as it will show asterisk installation menu where you can specify some installation settings and choose which plugins should be installed.

P.S. 
As per FreePBX about MySQL/MariaDB configuration: "The prompt will ask you for your current root password. Since you just installed MySQL, you most likely won’t have one, so leave it blank by pressing enter. Then the prompt will ask you if you want to set a root password. Do not set a root password. We secure the database automatically, as part of the install script.  Apart from that you can chose yes for the rest. This will remove some sample users and databases, disable remote root logins, and load these new rules so that MySQL immediately respects the changes we have made."

P.S P.S.
You may want to make FreePBX start automatically via Systemd startup script. For that just create text file /etc/systemd/system/freepbx.service and put below contents to it: 

[Unit]

Description=FreePBX VoIP Server

After=mariadb.service


 
[Service]

Type=oneshot

RemainAfterExit=yes

ExecStart=/usr/sbin/fwconsole start -q

ExecStop=/usr/sbin/fwconsole stop -q


 
[Install]
WantedBy=multi-user.target


Then run following commands:
#systemctl enable freepbx.service
and 
#systemctl start freepbx

If you have any comments or questions please post them to http://sysopnotes.net/en/freepbx-install-on-centos-7/
