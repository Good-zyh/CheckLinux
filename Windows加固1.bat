
echo 现在开始Windows安全加固，确认请按任意键
pause
echo [version] >account.inf REM帐户口令授权配置模块
echo signature="$CHICAGO$" >>account.inf
echo [System Access] >>account.inf
echo MinimumPasswordLength=6 >>account.inf REM 修改帐户密码最小长度为6
echo PasswordComplexity=1 >>account.inf REM 开启帐户密码复杂性要求
echo MaximumPasswordAge=90 >>account.inf REM 修改帐户密码最长留存期为90天
echo PasswordHistorySize=5 >>account.inf REM 修改强制密码历史为5次
echo EnableGuestAccount=0 >>account.inf REM 禁用Guest帐户
echo LockoutBadCount=6 >>account.inf REM 设定帐户锁定阀值为6次
secedit /configure /db account.sdb /cfg account.inf /log account.log
del account.*

echo [version] >rightscfg.inf
REM 授权配置
echo signature="$CHICAGO$" >>rightscfg.inf
echo [Privilege Rights] >>rightscfg.inf
echo seremoteshutdownprivilege=Administrators >>rightscfg.inf
REM从远端系统强制关机只指派给Administrators组
echo seshutdownprivilege=Administrators >>rightscfg.inf
REM关闭系统仅指派给Administrators组
echo setakeownershipprivilege=Administrators >>rightscfg.inf
REM 取得文件或其它对象的所有权仅指派给Administrators
echo seinteractivelogonright=Administrators >> rightscfg.inf
REM 在本地登陆权限仅指派给Administrators
echo senetworklogonright=Administrators >>rightscfg.inf
REM只允许Administrators从网络访问
secedit /configure /db rightscfg.sdb /cfg rightscfg.inf /log rightscfg.log /quiet
del rightscfg.*

echo [version] >audit.inf REM 日志配置
echo signature="$CHICAGO$" >>audit.inf
echo [Event Audit] >>audit.inf
echo AuditSystemEvents=3 >>audit.inf REM
开启审核系统事件
echo AuditObjectAccess=3 >>audit.inf
REM 开启审核对象访问
echo AuditPrivilegeUse=3 >>audit.inf
REM 开启审核特权使用
echo AuditPolicyChange=3 >>audit.inf
REM 开启审核策略更改
echo AuditAccountManage=3 >>audit.inf
REM 开启审核帐户管理
echo AuditProcessTracking=3 >>audit.inf
REM 开启审核过程跟踪
echo AuditDSAccess=3 >>audit.inf
REM 开启审核目录服务访问
echo AuditLogonEvents=3 >>audit.inf
REM 开启审核登陆事件
echo AuditAccountLogon=3 >>audit.inf
REM 开启审核帐户登陆事件
echo AuditLog >>audit.inf
echo MaximumLogSize=8192 >>logcfg.inf REM 设置应用日志文件最大8192KB
echo AuditLogRetentionPeriod=0 >>logcfg.inf REM设置当达到最大的日志尺寸时按需要改写事件
echo RestrictGuestAccess=1 >>logcfg.inf REM设置限制GUEST访问应用日志
echo [Security Log] >>logcfg.inf REM设置安全日志
echo MaximumLogSize=8192 >>logcfg.inf REM 设置安全日志文件最大8192KB
echo AuditLogRetentionPeriod=0 >>logcfg.inf REM设置当达到最大的日志尺寸时按需要改写事件
echo RestrictGuestAccess=1 >>logcfg.inf REM设置限制GUEST访问安全日志
echo [Application Log] >>logcfg.inf REM设置应用日志
echo MaximumLogSize=8192 >>logcfg.inf 设置安全日志文件最大8192KB
echo AuditLogRetentionPeriod=0 >>logcfg.inf REM设置当达到最大的日志尺寸时按需要改写事件
echo RestrictGuestAccess=1 >>logcfg.inf REM设置限制GUEST访问安全日志
secedit /configure /db audit.sdb /cfg audit.inf /log audit.log /quiet
del audit.*

REM 共享配置
REM 清除admin$共享
net share admin$ /del 
REM 清除ipc$共享
net share ipc$ /del
REM 清除C盘共享
net share c$ /del   
REM 清除D盘共享
net share d$ /del   

REM IP协议配置
REM 启用SYN攻击保护
@echo Windows Registry Editor Version 5.00>>SynAttack.reg 
@echo [HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services]>>SynAttack.reg 
@echo "SynAttackProtect"=dword:2>>SynAttack.reg
@echo "TcpMaxPortsExhausted"=dword:5>>SynAttack.reg
@echo "TcpMaxHalfOpen"=dword:500>>SynAttack.reg
@echo "TcpMaxHalfOpenRetried"=dword:400>>SynAttack.reg
@regedit /s SynAttack.reg
@del SynAttack.reg

REM 启用屏幕保护程序
@echo Windows Registry Editor Version 5.00>>scrsave.reg 
@echo [HKEY_CURRENT_USER\Control Panel\Desktop]>>scrsave.reg 
@echo "ScreenSaveActive"="1">>scrsave.reg
@echo "ScreenSaverIsSecure"="1">>scrsave.reg
@echo "ScreenSaveTimeOut"="300">>scrsave.reg
@echo "SCRNSAVE.EXE"="d:\\WINDOWS\\system32\\logon.scr">>scrsave.reg
@regedit /s scrsave.reg
@del scrsave.reg

REM “Microsoft网络服务器”设置为“在挂起会话之前所需的空闲时间”为15分钟
@echo Windows Registry Editor Version 5.00>>lanmanautodisconn.reg 
@echo [HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\lanmanserver\parameters]>>lanmanautodisconn.reg 
@echo "autodisconnect"=dword:0000000f>>lanmanautodisconn.reg 
@regedit /s lanmanautodisconn.reg
@del lanmanautodisconn.reg

REM 关闭自动播放
@echo Windows Registry Editor Version 5.00>>closeautorun.reg
@echo [HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer]>>closeautorun.reg
@echo  "NoDriveTypeAutoRun"=dword:000000ff>>closeautorun.reg
@regedit /s closeautorun.reg
@del closeautorun.reg
