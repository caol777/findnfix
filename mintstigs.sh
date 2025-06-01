#!/bin/bash

# Create the .conf file in /etc/security/limits.d/
echo "* hard maxlogins 10" >> /etc/security/limits.conf

# Print a success message
echo "The .conf file has been created successfully."

LOGIN_DEFS="/etc/login.defs"

# Ensure secure login.defs settings
grep -qxF 'ENCRYPT_METHOD SHA512' "$LOGIN_DEFS" || echo 'ENCRYPT_METHOD SHA512' >> "$LOGIN_DEFS"
grep -qxF 'CREATE_HOME yes' "$LOGIN_DEFS" || echo 'CREATE_HOME yes' >> "$LOGIN_DEFS"
grep -qxF 'FAIL_DELAY 4' "$LOGIN_DEFS" || echo 'FAIL_DELAY 4' >> "$LOGIN_DEFS"
grep -qxF 'UMASK 077' "$LOGIN_DEFS" || echo 'UMASK 077' >> "$LOGIN_DEFS"
grep -qxF 'PASS_MIN_LEN 15' "$LOGIN_DEFS" || echo 'PASS_MIN_LEN 15' >> "$LOGIN_DEFS"

# Backup the original GRUB config
cp /etc/default/grub /etc/default/grub.bak

# Set audit=1 in GRUB_CMDLINE_LINUX and GRUB_CMDLINE_LINUX_DEFAULT
sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="audit=1"/' /etc/default/grub
sed -i 's/^GRUB_CMDLINE_LINUX=.*/GRUB_CMDLINE_LINUX="audit=1"/' /etc/default/grub
# If the lines don't exist, append them
grep -q '^GRUB_CMDLINE_LINUX_DEFAULT=' /etc/default/grub || echo 'GRUB_CMDLINE_LINUX_DEFAULT="audit=1"' >> /etc/default/grub
grep -q '^GRUB_CMDLINE_LINUX=' /etc/default/grub || echo 'GRUB_CMDLINE_LINUX="audit=1"' >> /etc/default/grub

# Update GRUB
update-grub


# Enforce APT to reject unauthenticated packages
echo "Configuring APT to disallow unauthenticated packages..."

# Create or update the config file
echo 'APT::Get::AllowUnauthenticated "false";' | sudo tee /etc/apt/apt.conf.d/99stig-unauthenticated

# Set correct permissions
sudo chmod 644 /etc/apt/apt.conf.d/99stig-unauthenticated


# Set journalctl permissions to 740
echo "Setting permissions on /usr/bin/journalctl to 740..."
chmod 740 /usr/bin/journalctl

# Verify
ls -l /usr/bin/journalctl



echo "Disabling Ctrl+Alt+Delete in GUI..."

# Create dconf directory if it doesn't exist
mkdir -p /etc/dconf/db/local.d

# Write the configuration
cat <<EOF > /etc/dconf/db/local.d/00-screensaver
[org/gnome/settings-daemon/plugins/media-keys]
logout=''
EOF

# Apply the changes
dconf update

echo "Disabling USB mass storage kernel module..."

# Create or append to stig.conf
echo 'install usb-storage /bin/false' >> /etc/modprobe.d/stig.conf
echo 'blacklist usb-storage' >> /etc/modprobe.d/stig.conf

sudo passwd -l root


echo "Setting shell timeout to 15 minutes (900 seconds)..."

# Create or append the timeout setting
echo 'TMOUT=900' >> /etc/profile.d/99-terminal_tmout.sh
chmod 644 /etc/profile.d/99-terminal_tmout.sh

# Apply to current session (optional)
export TMOUT=900
