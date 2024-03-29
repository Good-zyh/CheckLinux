
#!/bin/bash

#设置密码复杂度
if [ -z "`cat /etc/pam.d/system-auth | grep -v "^#" | grep "pam_cracklib.so"`" ];then
  sed -i '/password    required      pam_deny.so/a\password    required      pam_cracklib.so  try_first_pass minlen=8 ucredit=-1   lcredit=-1   ocredit=-1 dcredit=-1 retry=3 difok=5' /etc/pam.d/system-auth
fi
#密码输入失败3次，锁定5分钟
sed -i 's#auth        required      pam_env.so#auth        required      pam_env.so\nauth       required       pam_tally.so  onerr=fail deny=3 unlock_time=300\nauth           required     /lib/security/$ISA/pam_tally.so onerr=fail deny=3 unlock_time=300#' /etc/pam.d/system-auth

#修改默认访问权限
sed -i '/UMASK/s/077/027/' /etc/login.defs

#设置重要文件目录权限
chmod 644 /etc/passwd  
chmod 600 /etc/xinetd.conf 
chmod 600 /etc/inetd.conf  
chmod 644 /etc/group  
chmod 000 /etc/shadow  
chmod 644 /etc/services  
chmod 600 /etc/security
#chmod 750 /etc/        #启动了nscd服务导致设置权限以后无法登陆 #系统默认755可以接受  #不能修改，如果修改polkit的服务就启动不了
chmod 750 /etc/rc6.d  
chmod 750 /tmp  
chmod 750 /etc/rc0.d/  
chmod 750 /etc/rc1.d/  
chmod 750 /etc/rc2.d/  
chmod 750 /etc/rc4.d  
chmod 750 /etc/rc5.d/  
chmod 750 /etc/rc3.d  
chmod 750 /etc/rc.d/init.d/  
chmod 600 /etc/grub.conf
chmod 600 /boot/grub/grub.conf
chmod 600 /etc/lilo.conf

#检查用户umask设置
sed -i '/umask/s/002/077/' /etc/csh.cshrc
sed -i '/umask/s/002/077/' /etc/bashrc
sed -i '/umask/s/002/077/' /etc/profile
csh_login=`cat /etc/csh.login | grep -i "umask"`
if [ -z "$csh_login" ];then
  echo -e "/numask 077" >>/etc/csh.login
fi


#FTP安全设置 #如果安装了FTP服务 可以进行这个设置
vsftpd_conf=`find /etc/ -maxdepth 2 -name vsftpd.conf`
if [ ! -z "$vsftpd_conf" ];then
  sed -i '/anonymous_enable/s/YES/NO/' $vsftpd_conf
fi

ftpuser=`find /etc/ -maxdepth 2 -name ftpusers`
if [ ! -z "$ftpuser" ] && [ -z "`cat $ftpuser | grep -v "^#" | grep root`"];then
  echo "root" >>$ftpuser
fi

sed -i '/^ftp/d' /etc/passwd

#重要文件属性设置
chattr +i /etc/passwd
chattr +i /etc/shadow
chattr +i /etc/group
chattr +i /etc/gshadow
chattr +a /var/log/messages
#chattr +i /var/log/messages.*

#检查core dump 设置
chk_core=`grep core /etc/security/limits.conf | grep -v "^#"`
if [ -z "$chk_core" ];then
  echo "*               soft    core            0"  >> /etc/security/limits.conf
  echo "*               hard    core            0"  >> /etc/security/limits.conf
fi

#删除潜在危险文件 可以先检查一下是否有危险文件，如果没有的话，就不需要执行这个
hosts_equiv=`find / -maxdepth 3 -name hosts.equiv 2>/dev/null`
if [ ! -z "$hosts_equiv" ];then
  mv "$hosts_equiv" "$hosts_equiv".bak
fi

_rhosts=`find / -maxdepth 3 -name .rhosts 2>/dev/null`
if [ ! -z "$_rhosts" ];then
  mv "$_rhosts" "$_rhosts".bak
fi

_netrc=`find / -maxdepth 3 -name .netrc 2>/dev/null`
if [ ! -z "$_netrc" ];then
  mv "$_netrc" "$_netrc".bak
fi

#检查系统内核参数配置,修改只当次生效，重启需重新设置
sysctl -w net.ipv4.conf.all.accept_source_route="0"
sysctl -w net.ipv4.conf.all.accept_redirects="0"
sysctl -w net.ipv4.icmp_echo_ignore_broadcasts="1"
sysctl -w net.ipv4.conf.all.send_redirects="0"
sysctl -w net.ipv4.ip_forward="0"

#打开syncookie，缓解syn fiood攻击
echo 1 > /proc/sys/net/ipv4/tcp_syncookies

#不响应ICMP请求
echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_all

#防syn攻击优化，提高未连接队列大小
sysctl -w net.ipv4.tcp_max_syn_backlog="2048"

#检查拥有suid和sgid权限文件并修改文件权限为755 目前这些不需要改变权限，需要定期巡检
find /usr/bin/chage /usr/bin/gpasswd /usr/bin/wall /usr/bin/chfn /usr/bin/chsh /usr/bin/newgrp /usr/bin/write /usr/sbin/usernetctl /bin/mount /bin/umount /bin/ping /sbin/netreport -type f -perm /6000 | xargs chmod 755
