#!/bin/bash

workdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
file="$workdir/$0"

hostname=`hostname`

echo -e "# file: $file \n# hostname: $hostname \n\n"
rm $file.*

# mailleri listeleme
cat /var/log/exim_mainlog |grep -E "$(date +"%d %H":)" |grep '=>' |grep -E "outsmtp|queued" |awk '{print $5,$6}' |grep -vE "google|gmail|bounce|${hostname}" | sed 's/<//g;s/>//g;s/(//g;s/)//g;s/,//g;s/ R=dkim_lookuphost//g;s/ R=lookuphost//g;s/ /\n/g' > ${file}.maillist
# cat ${file}.maillist

# tekil domainleri alma
cat /var/log/exim_mainlog |grep -E "$(date +"%d %H":)" |grep '=>' |grep -E "outsmtp|queued" |awk '{print $5,$6}' |grep -vE "google|gmail|bounce|${hostname}" | sed 's/<//g;s/>//g;s/(//g;s/)//g;s/,//g;s/ R=dkim_lookuphost//g;s/ /\n/g' | sed 's/@/ /g' |awk {'print $2'} |s$
# cat ${file}.domain


while read domain
do
ara=`grep $domain /etc/localdomains |wc -l`
        if [ $ara == 1 ]; then
                echo "# $domain bizde calisiyor"
                echo $domain >> $file.bizdecalisan
        fi
	cat ${file}.maillist |grep $domain >> ${file}.sira
done < $file.domain

# cat ${file}.sira


exit
