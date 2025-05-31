#!/bin/bash

# Append the configuration lines to /etc/security/limits.conf
echo "* hard core 0
* hard maxlogins 10" >> /etc/security/limits.conf

# Print a success message
echo "The .conf file has been updated successfully."
