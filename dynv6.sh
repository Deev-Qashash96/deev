#!/bin/sh -e
hostname=$1
device=$2
file=$HOME/.dynv6.addr6
[ -e $file ] && old=`cat $file`

if [ -z "$hostname" -o -z "$TOKEN" ]; then
  echo "Usage: TOKEN=<your-authentication-token> $0 your-name.dynv6.net [device]"
  exit 1
fi

if [ -n "$device" ]; then
  device="dev $device"
fi
current=$(ip -6 addr list scope global dynamic $device | grep -v " fd" | egrep -o '([0-9a-f:]+)/[0-9]+' | head -n1)

if [ -e /usr/bin/curl ]; then
  bin="curl -fsS"
elif [ -e /usr/bin/wget ]; then
  bin="wget -O-"
else
  echo "neither curl nor wget found"
  exit 1
fi

if [ -z "$current" ]; then
  echo "no IPv6 address found"
  exit 1
fi

if [ "$old" = "$current" ]; then
  echo "IPv6 address unchanged"
  exit
fi

# send addresses to dynv6
$bin "http://dynv6.com/api/update?hostname=$hostname&ipv6=$current&token=$TOKEN"
$bin "http://ipv4.dynv6.com/api/update?hostname=$hostname&ipv4=auto&token=$TOKEN"

# save current address
echo $current > $file
