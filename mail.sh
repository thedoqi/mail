#!/bin/bash
workdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
file="$workdir/$0"
hostname=`hostname`
echo -e "# file: $file \n# hostname: $hostname \n\n"
rm -f $file.*
# mailleri listeleme
cat /var/log/exim_mainlog |grep -E "$(date +"%d %H":)" |grep '=>' |grep -E "outsmtp|queued" |awk '{print $5,$6}' |grep -vE "google|gmail|bounce|${hostname}" | sed 's/<//g;s/>//g;s/(//g;s/)//g;s/,//g;s/R=dkim_lookuphost//g;s/R=lookuphost//g;s/ /\n/g' > ${file}.maillist
# cat ${file}.maillist
# tekil domainleri alma
cat /var/log/exim_mainlog |grep -E "$(date +"%d %H":)" |grep '=>' |grep -E "outsmtp|queued" |awk '{print $5,$6}' |grep -vE "google|gmail|bounce$(hostname)" |sed 's/<//g;s/>//g;s/(//g;s/)//g;s/,//g;s/R=dkim_lookuphost//g;s/ /\n/g' | sed 's/@/ /g' |awk {'print $2'} |sort -n |uniq |grep "." > ${file}.domain
# cat ${file}.domain
while read domain
do
ara="grep $domain /etc/localdomains |wc -l"
        if [ $ara == 1 ]; then
                echo "# $domain bizde calisiyor"
                echo $domain >> $file.bizdecalisan
        fi
	cat ${file}.maillist |grep $domain >> ${file}.sira
done < ${file}.domain
# cat ${file}.sira
cat /root/mail/${file}.sira | sort | uniq -c | sort -n | awk -v limit="$thold" '$1 > limit' >> /usr/local/apache/htdocs/engelli.txt
cat /root/mail/${file}.sira | sort | uniq -c | sort -n | awk -v limit="$thold" '$1 > limit{print $2}' > /root/${file}.nedir
cp /root/${file}.nedir /root/${file}.out
sed -i "s;@; ;" /root/${file}.nedir
awk '{print $2}' /root/${file}.nedir > /root/${file}.awk
while IFS= read -r line
        do
          	cat /etc/trueuserdomains |grep $line >> /root/${file}.oldu
done < /root/${file}.awk
awk '{print $2}' /root/${file}.oldu > /root/${file}.awk2
paste -d'\n' /root/${file}.awk2 /root/${file}.out| while read f1 && read f2; do
echo "/usr/local/cpanel/bin/uapi --user="$f1" Email suspend_outgoing email="$f2""
done
exit
