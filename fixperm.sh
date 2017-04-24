#!/bin/bash
set -ex

if [ $EUID -ne 0 ]; then
    echo "$0 must be run as root" 1>&2
    exit 1
fi

# Fixing the file context on /usr/libexec/ipa/ipa-custodia
/sbin/restorecon -F -R -v /usr/libexec/ipa/ipa-custodia

# Fixing the file context on /etc/ipa/custodia
if [ -d /etc/ipa/custodia ]; then
    /sbin/restorecon -F -R -v /etc/ipa/custodia
fi

# Fixing the file context on /var/log/ipa-custodia.audit.log
if [ -f /var/log/ipa-custodia.audit.log ]; then
    /sbin/restorecon -F -R -v /var/log/ipa-custodia.audit.log
fi

if [ -d /etc/pki/pki-tomcat/alias ]; then
    # list permissions before we change them
    ls -ladZ /etc/pki/pki-tomcat \
        /etc/pki/pki-tomcat/alias \
        /etc/pki/pki-tomcat/alias/* \
        /etc/pki/pki-tomcat/password.conf

    # ipa-custodia needs to enter the directory as root
    chgrp root /etc/pki/pki-tomcat
    chmod g+x /etc/pki/pki-tomcat

    # ipa-custodia needs to enter, read and write NSSDB
    chgrp root /etc/pki/pki-tomcat/alias
    chmod g+rwx /etc/pki/pki-tomcat/alias

    # ipa-custodia needs to be able to modify NSSDB
    chgrp root /etc/pki/pki-tomcat/alias/*.db
    chmod g+rw /etc/pki/pki-tomcat/alias/*.db

    # ipa-custodia needs to read NSSDB's password file
    chgrp root /etc/pki/pki-tomcat/password.conf
    chmod g+r /etc/pki/pki-tomcat/password.conf

    ls -ladZ /etc/pki/pki-tomcat \
        /etc/pki/pki-tomcat/alias \
        /etc/pki/pki-tomcat/alias/* \
        /etc/pki/pki-tomcat/password.conf
else
    echo "/etc/pki/pki-tomcat/alias does not exist"
fi
