#!/bin/bash

#==============================================================================
# Linux SSH Security & Initialization Script
# Author: YourName (GitHub: YourUsername)
# Description: Automate SSH port change, Key-based auth, and system hardening.
# Support: Debian/Ubuntu, CentOS/RHEL/Rocky/AlmaLinux
#==============================================================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 日志函数
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }

# 1. 环境检查
check_env() {
    if [ "$EUID" -ne 0 ]; then
        log_error "请使用 root 权限运行此脚本。"
        exit 1
    fi

    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
    else
        log_error "无法识别的操作系统。"
        exit 1
    fi
    log_info "当前操作系统: $OS"
}

# 2. 备份配置
backup_config() {
    local bkp="/etc/ssh/sshd_config.bak.$(date +%F_%H%M%S)"
    cp /etc/ssh/sshd_config "$bkp"
    log_success "备份完成: $bkp"
}

# 3. SSH 端口配置
setup_port() {
    echo -e "\n${BLUE}>>> SSH 端口设置${NC}"
    read -p "请输入新的 SSH 端口 (默认 22): " NEW_PORT
    NEW_PORT=${NEW_PORT:-22}

    if [ "$NEW_PORT" != "22" ]; then
        sed -i "s/^#\?Port .*/Port $NEW_PORT/" /etc/ssh/sshd_config
        # 配置防火墙
        if command -v ufw >/dev/null; then
            ufw allow "$NEW_PORT"/tcp
        elif command -v firewall-cmd >/dev/null; then
            firewall-cmd --permanent --add-port="$NEW_PORT"/tcp
            firewall-cmd --reload
        fi
        log_success "端口已修改为: $NEW_PORT (请确保云平台安全组已放行)"
    fi
}

# 4. 密钥登录与安全加固
setup_hardening() {
    echo -e "\n${BLUE}>>> 密钥配置与加固${NC}"
    
    # 确保 .ssh 目录存在
    mkdir -p /root/.ssh && chmod 700 /root/.ssh

    read -p "是否生成并启用新的 SSH 密钥登录? [y/N]: " gen_key
    if [[ "$gen_key" =~ ^[Yy]$ ]]; then
        local key_path="/root/.ssh/id_rsa_$(date +%s)"
        ssh-keygen -t rsa -b 4096 -f "$key_path" -N "" -C "admin@$(hostname)"
        cat "${key_path}.pub" >> /root/.ssh/authorized_keys
        chmod 600 /root/.ssh/authorized_keys
        
        log_warn "--- 重要: 你的私钥如下，请保存 ---"
        cat "$key_path"
        log_warn "--- 私钥显示完毕 ---"
        rm -f "$key_path" "${key_path}.pub"
    fi

    # 应用加固配置
    log_info "正在应用 SSH 加固规则..."
    sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
    sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication no/' /etc/ssh/sshd_config
    sed -i 's/^#\?MaxAuthTries .*/MaxAuthTries 3/' /etc/ssh/sshd_config
}

# 5. 重启服务
restart_service() {
    if sshd -t; then
        systemctl restart ssh || systemctl restart sshd
        log_success "SSH 服务重启成功！"
    else
        log_error "SSH 配置检查失败，请检查 /etc/ssh/sshd_config"
        exit 1
    fi
}

main() {
    check_env
    backup_config
    setup_port
    setup_hardening
    restart_service
    echo -e "\n${GREEN}配置完成！请保持当前连接，新开一个窗口测试登录后再关闭。${NC}"
}

main
