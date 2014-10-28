#!/bin/sh -e
hostname=$1
current=$(ip -6 addr list scope global dynamic temporary | grep -v "fd00" | egrep -o '([0-9a-f:]+)/[0-9]+' | head -n1)
file=$HOME/.dynv6.addr6
[ -e $file ] && old=`cat $file`
 
if [ -z "$hostname" -o -z "$TOKEN" ]; then
echo "Usage: TOKEN=<your-authentication-token> $0 your-name.dynv6.net"
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
curl -fsS "http://dynv6.com/api/update?hostname=$hostname&ipv6=$current&token=$TOKEN"
curl -fsS "http://ipv4.dynv6.com/api/update?hostname=$hostname&ipv4=auto&token=$TOKEN"
 
# save current address
echo $current > $file