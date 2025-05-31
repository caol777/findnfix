#!/bin/bash

# Append the configuration lines to /etc/security/limits.conf
echo "* hard core 0
* hard maxlogins 10" >> /etc/security/limits.conf

# Print a success message
echo "The .conf file has been updated successfully."

# More fixes
echo "declare -xr TMOUT=600" > /etc/profile.d/tmout.sh
echo "LogLevel VERBOSE" > /etc/ssh/sshd_config.d/40-loglevel.conf
#!/bin/bash

# Function to ensure a line is present in a file
ensure_line_in_file() {
    local line="$1"
    local file="$2"
    grep -qxF "$line" "$file" || echo "$line" >> "$file"
}

# Ensure the line is present in /etc/rsyslog.conf or a .conf file in /etc/rsyslog.d/
line="auth.*;authpriv.*;daemon.* /var/log/secure"
rsyslog_conf="/etc/rsyslog.conf"
rsyslog_d_conf="/etc/rsyslog.d/secure_logging.conf"

if grep -q "$line" "$rsyslog_conf"; then
    echo "The line is already present in $rsyslog_conf"
else
    if grep -qr "$line" /etc/rsyslog.d/; then
        echo "The line is already present in a .conf file within /etc/rsyslog.d/"
    else
        ensure_line_in_file "$line" "$rsyslog_d_conf"
        echo "The line has been added to $rsyslog_d_conf"
    fi
fi

# Print a success message
echo "The script has been executed successfully."



# Update the SSH client configuration to use only FIPS 140-3 approved ciphers
ssh_ciphers="Ciphers aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes128-ctr"
ssh_config="/etc/crypto-policies/back-ends/openssh.config"
ensure_line_in_file "$ssh_ciphers" "$ssh_config"
echo "The SSH client configuration has been updated with FIPS 140-3 approved ciphers."

# Print a success message
echo "The script has been executed successfully. A reboot is required for the changes to take effect."

sudo dnf reinstall openssh-clients



LOGIN_DEFS="/etc/login.defs"

# Ensure secure login.defs settings
grep -qxF 'ENCRYPT_METHOD SHA512' "$LOGIN_DEFS" || echo 'ENCRYPT_METHOD SHA512' >> "$LOGIN_DEFS"
grep -qxF 'CREATE_HOME yes' "$LOGIN_DEFS" || echo 'CREATE_HOME yes' >> "$LOGIN_DEFS"
grep -qxF 'FAIL_DELAY 4' "$LOGIN_DEFS" || echo 'FAIL_DELAY 4' >> "$LOGIN_DEFS"
grep -qxF 'UMASK 077' "$LOGIN_DEFS" || echo 'UMASK 077' >> "$LOGIN_DEFS"
grep -qxF 'PASS_MIN_LEN 15' "$LOGIN_DEFS" || echo 'PASS_MIN_LEN 15' >> "$LOGIN_DEFS"


# Ensure libreswan crypto policy is included in /etc/ipsec.conf
IPSEC_CONF="/etc/ipsec.conf"
INCLUDE_LINE="include /etc/crypto-policies/back-ends/libreswan.config"

if ! grep -Fxq "$INCLUDE_LINE" "$IPSEC_CONF"; then
    echo "$INCLUDE_LINE" >> "$IPSEC_CONF"
    echo "Added libreswan crypto policy include to $IPSEC_CONF"
else
    echo "Libreswan crypto policy include already present in $IPSEC_CONF"
fi
