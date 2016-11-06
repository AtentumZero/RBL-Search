#!/bin/sh

# rblsearch
# A basic shell script to check if an IP address is listed on an IP and/or Domain based Blacklist
# Example command: ./rblsearch.sh 192.168.0.2

# IP-based Blacklists
# Feel free to add to this list, a list of commonly used lists are available at mxtoolbox.com

BLISTS="
    cbl.abuseat.org
    bl.spamcop.net
    b.barracudacentral.org
    dnsbl-1.uceprotect.net
    psbl.surriel.com
    dnsbl.sorbs.net
    spam.dnsbl.sorbs.net
    zen.spamhaus.org
    bcl.spamhaus.org
    pbl.spamhaus.org
    sbl.spamhaus.org
    xbl.spamhaus.org
    swl.spamhaus.org
    multi.surbl.org
    iadb.isipp.com
    ips.backscatterer.org
    hostkarma.junkemailfilter.com
    aspews.ext.sorbs.net
"

#Domain-based Blacklists
#Feel free to add to this list, a list of commonly used lists are available at mxtoolbox.com

DLISTS="
    dbl.spamhaus.org
    nobl.junkemailfilter.com
    ubl.nszones.com
    uribl.spameatingmonkey.net
    hostkarma.junkemailfilter.com
"

ERROR() {
  echo $0 ERROR: $1 >&2
  exit 2
}

# Checks for a valid IP address
[ $# -ne 1 ] && ERROR 'Please input a single IP address'

reverse=$(echo $1 |
  sed -ne "s~^\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)$~\4.\3.\2.\1~p")

if [ "x${reverse}" = "x" ] ; then
      ERROR  "'$1' is not a valid IP address"
      exit 1
fi

RDNS=$(dig +short -x $1)

printf "\n Searching for $1 on major IP blacklists...\n"
for BL in ${BLISTS} ; do
    printf "%-40s" " ${reverse}.${BL}."
    IPL="$(dig @8.8.8.8 +short -t a ${reverse}.${BL}.)"
    IPT="$(dig @8.8.4.4 +short -t txt ${reverse}.${BL}.)"
    echo ${IPL:----} ${IPT:----} 
done

printf "\nSearching for ${RDNS} on major Domain-based blacklists... \n"
for DL in ${DLISTS} ; do
     printf "%-40s" " ${RDNS}${DL}." 
     DNL="$(dig @8.8.8.8 +short ${RDNS}${DL}.)"
     DNT="$(dig @8.8.4.4 +short TXT ${RDNS}${DL}.)"
     echo ${DNL:----} ${DNT:----} 
done
printf "\n"
