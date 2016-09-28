#!/bin/sh
interface="$1"
OS=`uname -s`
MYNAME="$0"

if [ x"${interface}" = "x" ]; then
  echo "usage ${MYNAME} [ interface ]"
  exit 1
fi

if [ x"${OS}" = "x" ]; then
    echo "${MYNAME}: cannot identify the OS"
    exit 1
fi

if [ "${OS}" != "OpenBSD" ]; then
    echo "${MYNAME}: supports OpenBSD only"
    exit 1
fi

if ifconfig "${interface}" >/dev/null 2>&1; then
    ifconfig "${interface}" destroy
fi
sh /etc/netstart "${interface}"
