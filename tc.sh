infractus:/etc# cat /etc/autoexec/tc.sh
#!/bin/bash

#reset qdics
tc qdisc del dev ${INET} root handle 1: 2>/dev/null

#maximum upload value
MAXUP=1900kbit

# those should sum to MAXUP
PHONE_RATE=70kbit
HIGH_PRIO_RATE=100kbit
NETWORK_RATE=1770kbit
SERVER_RATE=100kbit


PHONE_CEIL=300kbit

INET=eth0

#set main qdisc
tc qdisc add dev ${INET} root handle 1: htb default 12

#add root class
tc class add dev ${INET} parent 1: classid 1:1 htb rate ${MAXUP} ceil ${MAXUP}

#traffic control

#tutaj trafi telefon. zawsze pierwszy. niezaleznie od wszystkiego.
#here comes phone. No matter what, it's always first
tc class add dev ${INET} parent 1:1 classid 1:10 htb rate ${PHONE_RATE} ceil 300kbit prio 0

#here comes packets marked as high prio network traffic (skype? starcraft, quake, outcoming ssh, packages with SYN)
tc class add dev ${INET} parent 1:1 classid 1:11 htb rate ${HIGH_PRIO_RATE} ceil ${MAXUP} prio 1

#here comes network
tc class add dev ${INET} parent 1:1 classid 1:12 htb rate ${NETWORK_RATE} ceil ${MAXUP} prio 2

#here comes the rest - http, mail, and so on - services on infractus, and everything else marked as low priority
tc class add dev ${INET} parent 1:1 classid 1:13 htb rate ${SERVER_RATE} ceil ${MAXUP} prio 3

#stochastic
#obsluga stochastyczna
tc qdisc add dev ${INET} parent 1:11 handle 120: sfq perturb 10
tc qdisc add dev ${INET} parent 1:12 handle 130: sfq perturb 10
tc qdisc add dev ${INET} parent 1:13 handle 140: sfq perturb 10


#setting filtering on IPTABLES rules
tc filter add dev ${INET} parent 1:0 protocol ip prio 1 handle 1 fw classid 1:10
tc filter add dev ${INET} parent 1:0 protocol ip prio 2 handle 2 fw classid 1:11
tc filter add dev ${INET} parent 1:0 protocol ip prio 3 handle 3 fw classid 1:12
tc filter add dev ${INET} parent 1:0 protocol ip prio 4 handle 4 fw classid 1:13


#firewall classification
iptables -t mangle -A PREROUTING -s 10.0.1.2 -j MARK --set-mark 0x1
iptables -t mangle -A PREROUTING -s 10.0.1.2 -j RETURN

iptables -t mangle -A PREROUTING -p icmp -j MARK --set-mark 0x2
iptables -t mangle -A PREROUTING -p icmp -j RETURN
iptables -t mangle -I PREROUTING -p tcp -m tcp --tcp-flags SYN,RST,ACK SYN -j MARK --set-mark 0x2
iptables -t mangle -I PREROUTING -p tcp -m tcp --tcp-flags SYN,RST,ACK SYN -j RETURN

iptables -t mangle -A OUTPUT -o ${INET} -j MARK --set-mark 0x4

