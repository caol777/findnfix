#!/bin/bash

# Create the .conf file in /etc/security/limits.d/
echo "* hard maxlogins 10" > /etc/security/limits.conf

# Print a success message
echo "The .conf file has been created successfully."
