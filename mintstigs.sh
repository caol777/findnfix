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
