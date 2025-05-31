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


# Ensure OpenSSL uses system crypto policy
OPENSSL_CONF="/etc/pki/tls/openssl.cnf"
INCLUDE_LINE=".include = /etc/crypto-policies/back-ends/opensslcnf.config"

if ! grep -Fxq "$INCLUDE_LINE" "$OPENSSL_CONF"; then
    echo "$INCLUDE_LINE" >> "$OPENSSL_CONF"
    echo "Added OpenSSL crypto policy include to $OPENSSL_CONF"
else
    echo "OpenSSL crypto policy include already present in $OPENSSL_CONF"
fi

#!/bin/bash

AUDIT_RULES_FILE="/etc/audit/rules.d/audit.rules"

# Define audit rules
AUDIT_RULES=(
"-w /etc/sudoers -p wa -k identity"
"-w /etc/sudoers.d/ -p wa -k identity"
"-w /etc/passwd -p wa -k identity"
"-w /etc/shadow -p wa -k identity"
"-w /etc/group -p wa -k identity"
"-w /etc/gshadow -p wa -k identity"
"-w /etc/security/opasswd -p wa -k identity"
)

# Ensure each rule is present
for rule in "${AUDIT_RULES[@]}"; do
    if ! grep -Fxq "$rule" "$AUDIT_RULES_FILE"; then
        echo "$rule" >> "$AUDIT_RULES_FILE"
        echo "Added audit rule: $rule"
    else
        echo "Audit rule already present: $rule"
    fi
done

# Apply the audit rules
augenrules --load

echo "Audit rules applied. A reboot is recommended to ensure full enforcement."

#!/bin/bash

# Set CtrlAltDelBurstAction=none in /etc/systemd/system.conf
SYSTEM_CONF="/etc/systemd/system.conf"
if grep -q "^#*CtrlAltDelBurstAction=" "$SYSTEM_CONF"; then
    sed -i 's/^#*CtrlAltDelBurstAction=.*/CtrlAltDelBurstAction=none/' "$SYSTEM_CONF"
else
    echo "CtrlAltDelBurstAction=none" >> "$SYSTEM_CONF"
fi
echo "Set CtrlAltDelBurstAction=none in $SYSTEM_CONF"

# Ensure rescue mode requires authentication
RESCUE_SERVICE="/usr/lib/systemd/system/rescue.service"
if grep -q "^ExecStart=" "$RESCUE_SERVICE"; then
    sed -i 's|^ExecStart=.*|ExecStart=-/usr/lib/systemd/systemd-sulogin-shell rescue|' "$RESCUE_SERVICE"
else
    echo "ExecStart=-/usr/lib/systemd/systemd-sulogin-shell rescue" >> "$RESCUE_SERVICE"
fi
echo "Updated ExecStart in $RESCUE_SERVICE to require authentication"

# Reload systemd to apply changes
systemctl daemon-reexec
echo "Systemd daemon reloaded. Changes applied."
