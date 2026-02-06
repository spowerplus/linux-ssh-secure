# linux-ssh-secure
# Linux SSH 一键安全初始化脚本

一个简单、安全的 Shell 脚本，用于快速初始化和加固新 Linux 服务器的 SSH 配置。

## 功能特性
- [x] 自动备份原始 SSH 配置
- [x] 自定义或保持默认 SSH 端口
- [x] 自动检测防火墙（UFW/FirewallD）并开放新端口
- [x] 自动化 SSH 密钥生成（可选）
- [x] 禁用密码登录，仅允许密钥登录（提升 99% 的抗爆破能力）
- [x] 限制 Root 登录安全策略

## 注意事项

    安全组：如果你使用的是阿里云、腾讯云或 AWS，修改端口后必须在云端控制台放行相应端口。

    测试连接：脚本运行结束后，千万不要断开当前连接。请立即开启一个新的终端尝试连接，确保成功后再关闭当前会话。

    
## 使用方法

在使用前，请确保你了解脚本的操作逻辑：

```bash
wget https://raw.githubusercontent.com/spowerplus/linux-ssh-secure/refs/heads/main/ssh_secure.sh
chmod +x ssh_secure.sh
sudo ./ssh_secure.sh



