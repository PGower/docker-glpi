#!/bin/bash
# (C) Campbell Software Solutions 2015
set -e

# Automate installation
/bin/confd -onetime -backend env
# php /data/bin/install.php
# echo Applying configuration file security
# chmod 644 /data/upload/include/ost-config.php

#Launch supervisor to manage processes
exec /usr/bin/supervisord -c /supervisord.conf
