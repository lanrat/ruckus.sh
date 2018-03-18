#!/usr/bin/env bash

if ! [ -x "$(command -v snmpwalk)" ]; then
  echo 'Error: snmpwalk is not installed.' >&2
  exit 1
fi

if ! [ -x "$(command -v snmpget)" ]; then
  echo 'Error: snmpget is not installed.' >&2
  exit 1
fi


if [ "$#" -lt 1 ]; then
    echo "Usage $0 IP [IP]..."
    exit 1
fi

# for debug
#set -x

function printAP() {
    getAPInfo $1

    interfaces=$(getAPInterfaces $1)
    for i in $interfaces
    do
        echo "$(getWirelessInfo $1 $i)"
        clients=$(getAPInterfaceClients $1 $i)
        #echo "clients $clients"
        for c in $clients
        do
            getClientInfo $1 $i $c
        done
    done

}

function getAPInfo() {
    # ruckusDeviceName.0
    name=$(snmpGet $1 ".1.3.6.1.2.1.1.5.0")

    # ruckusDeviceLocation.0;
    location=$(snmpGet $1 ".1.3.6.1.2.1.1.6.0")

    # ruckusDeviceMacAddr.0;
    macaddr=$(snmpGet $1 ".1.3.6.1.4.1.25053.1.1.4.1.1.1.11.0")
    macaddr=$(cleanmac $macaddr)

    hostname=$(getHostnameFromIP $1)

    printf "%-10s            [%s]  %-13s  %-10s     %s\n" $name  $macaddr $1 $location $hostname
}

function getWirelessInfo() {
    # ruckusWLANChannel
    channel=$(snmpGet $1 ".1.3.6.1.4.1.25053.1.1.6.1.1.1.1.1.10.$2")

    # ruckusWLANSSID
    ssid=$(snmpGet $1 ".1.3.6.1.4.1.25053.1.1.6.1.1.1.1.1.1.$2")

    # ruckusWLANBSSID
    macaddr=$(snmpGet "-Ox $1" ".1.3.6.1.4.1.25053.1.1.6.1.1.1.1.1.2.$2")
    macaddr=$(cleanmac $macaddr)

    printf "%20s  [%s]                 ch%3s\n" $ssid $macaddr $channel
}

function getClientInfo() {
    # ruckusWLINKIIRemoteMAC
    macaddr=$(snmpGet "-Ox $1" .1.3.6.1.4.1.25053.1.1.15.1.1.1.2.1.5.$2.$3)
    macaddr=$(cleanmac $macaddr)

    # ruckusWLINKIIRssi
    signal=$(snmpGet $1 .1.3.6.1.4.1.25053.1.1.15.1.1.1.2.1.12.$2.$3)

    # ruckusWLINKIIUpTime
    # .1.3.6.1.4.1.25053.1.1.15.1.1.1.2.1.11.N.M
    # ruckusWLINKIIEstablishTime
    # .1.3.6.1.4.1.25053.1.1.15.1.1.1.2.1.10.N.M
    up=$(snmpGet $1 .1.3.6.1.4.1.25053.1.1.15.1.1.1.2.1.11.$2.$3)

    ip=$(getClientIPFromMAC $1 $2 $macaddr)

    hostname=$(getHostnameFromIP $ip)

    printf "                      [%s]  %-13s %3sdb %7ss  %s\n" $macaddr $ip $signal $up $hostname
}

function getAPInterfaces() {
    # ruckusWLANAdminStatus
    # 1 = up
    # 2 = down
    results="$(snmpWalk $1 ".1.3.6.1.4.1.25053.1.1.6.1.1.1.1.1.12" | grep ' 1$')"

    networkIDs="$(echo "${results}" | cut -d ' ' -f1 | rev | cut -d '.' -f1 | rev)"

    echo $networkIDs
}

function getAPInterfaceClients() {
    # ruckusWLINKIIRemoteMAC
    results="$(snmpWalk $1 ".1.3.6.1.4.1.25053.1.1.15.1.1.1.2.1.5.$2")"

    if echo $results | grep -q "No Such Instance currently exists at this OID";
    then
        echo ""
        return
    fi

    clientIDs="$(echo "${results}" | cut -d ' ' -f1 | rev | cut -d '.' -f1 | rev)"

    echo $clientIDs
}

function cleanmac() {
    t="${@%\"}" # remove end "
    t="${t#\"}" # remove leading "
    t=$(trim $t) # remove spaces
    t=${t// /:} # replace space with :
    echo $t
}

trim() {
    local var="$*"
    # remove leading whitespace characters
    var="${var#"${var%%[![:space:]]*}"}"
    # remove trailing whitespace characters
    var="${var%"${var##*[![:space:]]}"}"   
    echo -n "$var"
}

function mac2dec() {
    mac=${1//:/ }
    for i in $mac
    do
        echo -n .$((0x$i))
    done
    echo ""
}

function getClientIPFromMAC() {
    # ruckusWLANStaIpaddr
    decmac=$(mac2dec $3)
    ip=$(snmpGet $1 ".1.3.6.1.4.1.25053.1.1.6.1.1.2.2.1.16.$2.6$decmac")
    ip="${ip%\"}" # remove end "
    ip="${ip#\"}" # remove leading "
    echo $ip
}

function getHostnameFromIP() {
    if  [ -x "$(command -v dig)" ]; then
        dig -x $1 +short
        return
    fi

    if  [ -x "$(command -v nslookup)" ]; then
        nslookup $1 | grep arpa | cut -d ' ' -f3
        return
    fi

    if  [ -x "$(command -v host)" ]; then
        host $1 | rev | cut -f1 -d ' ' | rev
        return
    fi

    echo ""
}


function snmpGet() {
    echo "$(snmpget -Oqv -v2c -c public ${1} ${2})"
}

function snmpWalk() {
    echo "$(snmpwalk -Oxq -v2c -c public ${1} ${2})"
}

for ip in "$@"
do
    printAP $ip
    echo ""
done
