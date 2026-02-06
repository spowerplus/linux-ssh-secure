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

## 使用方法

在使用前，请确保你了解脚本的操作逻辑：

```bash
wget https://raw.githubusercontent.com/spowerplus/linux-ssh-secure/refs/heads/main/ssh_secure.sh
chmod +x ssh_secure.sh
sudo ./ssh_secure.sh
