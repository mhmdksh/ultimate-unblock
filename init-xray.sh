#! /bin/bash

check_root() {
    if [ $(id -u) != "0" ]; then
        echo "Error: You must be root to run this script"
        exit 1
    fi
}

config_os_params() {
    echo "Configuring system parameters..."
    
    # Function to check and set sysctl parameters
    set_sysctl_param() {
        local param="$1"
        local value="$2"
        
        if grep -q "^${param}" /etc/sysctl.conf; then
            # Parameter exists, check if value is different
            current_value=$(grep "^${param}" /etc/sysctl.conf | cut -d'=' -f2 | xargs)
            if [ "$current_value" != "$value" ]; then
                echo "Updating ${param} from ${current_value} to ${value}"
                sed -i "s|^${param}.*|${param} = ${value}|" /etc/sysctl.conf
            else
                echo "${param} already set to ${value}"
            fi
        else
            echo "Adding ${param} = ${value}"
            echo "${param} = ${value}" >> /etc/sysctl.conf
        fi
    }
    
    # Function to check and set limits parameters
    set_limits_param() {
        local user="$1"
        local type="$2"
        local item="$3"
        local value="$4"
        local pattern="${user}[[:space:]]*${type}[[:space:]]*${item}"
        
        if grep -q "^${pattern}" /etc/security/limits.conf; then
            current_value=$(grep "^${pattern}" /etc/security/limits.conf | awk '{print $4}')
            if [ "$current_value" != "$value" ]; then
                echo "Updating ${user} ${type} ${item} from ${current_value} to ${value}"
                sed -i "s|^${pattern}.*|${user} ${type} ${item} ${value}|" /etc/security/limits.conf
            else
                echo "${user} ${type} ${item} already set to ${value}"
            fi
        else
            echo "Adding ${user} ${type} ${item} ${value}"
            echo "${user} ${type} ${item} ${value}" >> /etc/security/limits.conf
        fi
    }
    
    # Configure sysctl parameters
    set_sysctl_param "net.ipv4.tcp_keepalive_time" "90"
    set_sysctl_param "net.ipv4.ip_local_port_range" "1024 65535"
    set_sysctl_param "net.ipv4.tcp_fastopen" "3"
    set_sysctl_param "net.core.default_qdisc" "fq"
    set_sysctl_param "net.ipv4.tcp_congestion_control" "bbr"
    set_sysctl_param "fs.file-max" "65535000"
    
    # Configure limits parameters
    set_limits_param "*" "soft" "nproc" "655350"
    set_limits_param "*" "hard" "nproc" "655350"
    set_limits_param "*" "soft" "nofile" "655350"
    set_limits_param "*" "hard" "nofile" "655350"
    set_limits_param "root" "soft" "nproc" "655350"
    set_limits_param "root" "hard" "nproc" "655350"
    set_limits_param "root" "soft" "nofile" "655350"
    set_limits_param "root" "hard" "nofile" "655350"
    
    echo "Applying sysctl changes..."
    sysctl -p
    echo "System parameter configuration completed"
}

config_xray() {
    echo "Pulling xray docker image"
    docker pull ghcr.io/xtls/xray-core:main
    echo "Image pulled"
    echo "Generating UUID"
    uuid=$(docker run -it --rm ghcr.io/xtls/xray-core:main uuid -i Secret)
    echo "UUID generated"
    echo "Generating x25519"
    x25519=$(docker run -it --rm ghcr.io/xtls/xray-core:main x25519)
    echo "x25519 generated"
    echo "Generating Short ID"
    short_id=$(openssl rand -hex 8)
    echo $uuid > xray-config.json
    echo $x25519 >> xray-config.json
    echo $short_id >> xray-config.json
    echo "Configuring Xray Done"
}

main() {
    check_root
    config_os_params
    config_xray
}

main