DOWN=`/usr/sbin/ipsec status protonvpn | grep '0 up'`
if [ $DOWN ]
then
  /usr/sbin/ipsec down protonvpn && /usr/sbin/ipsec up protonvpn | grep "establishing connection 'protonvpn' failed" && /usr/sbin/ipsec up protonvpn
else
  /usr/sbin/tcpdump -c1 -l -n -i vti100 -w /tmp/proton.pcap 2>/tmp/proton-status
  cat /tmp/proton-status | grep "0 packets received" && /usr/sbin/ipsec down protonvpn && /usr/sbin/ipsec up protonvpn && /usr/sbin/ipsec up protonvpn
  rm /tmp/proton.pcap
  rm /tmp/proton-status
fi
