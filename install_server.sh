#!/bin/sh
if [ "$(id -u)" -ne 0 ]; then
  echo "Please run with sudo"
  exit 1
fi
if [ -n "$1" ]; then
  FILENAME="$1"
else
  ARCH=$(uname -m)
  if [ -z "${ARCH##*arm*}" ]; then
    FILENAME="vhusbdarm"
  elif [ "$ARCH" = "mips" ]; then
    FILENAME="vhusbdmips"
  elif [ "$ARCH" = "mipsel" ]; then
    FILENAME="vhusbdmipsel"
  elif [ -z "${ARCH##*x86_64*}" ]; then
    FILENAME="vhusbdx86_64"
  elif [ -z "${ARCH##*aarch64*}" ]; then
    FILENAME="vhusbdarm64"
  else
    FILENAME="vhusbdi386"
  fi
fi
wget https://github.com/deker1176/VirtualHere-USB-Server-v4.3.3/blob/main/Linux/$FILENAME
chmod +x $FILENAME
mv $FILENAME /usr/local/sbin
mkdir -p /usr/local/etc/virtualhere
if [ -d "/etc/systemd/system" ]; then
  cat << EOF > /etc/systemd/system/virtualhere.service
[Unit]
Description=VirtualHere Server
After=network.target

[Service]
Type=forking
ExecStart=/usr/local/sbin/$FILENAME -b -c /usr/local/etc/virtualhere/config.ini

[Install]
WantedBy=multi-user.target
EOF
  systemctl daemon-reload
  systemctl enable virtualhere.service
  systemctl start virtualhere.service
else
  echo "Error, only systemd is supported"
fi
