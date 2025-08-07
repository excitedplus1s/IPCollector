#! /usr/bin/env sh
SUBNETS=$(cat ip_range.txt | awk '{print $3}')
DOMAINS=$(cat domain.txt)
for domain in $DOMAINS; do
    mkdir -p $domain
    touch $domain/ipv4.txt
    touch $domain/ipv6.txt
    for subnet in $SUBNETS; do
        case $subnet in
        *":"*) 
            dns=$(awk 'BEGIN{srand();} {print rand(), $0;}' dns4.txt | sort -k1,1n | head -n 1 | awk '{print $2}')
            dig $domain @$dns -t AAAA +subnet=$subnet +short | grep -v ";" 2>/dev/null >> $domain/ipv6.txt
            cat $domain/ipv6.txt | sort |uniq > $domain/ipv6_u.txt
            mv $domain/ipv6_u.txt $domain/ipv6.txt
            ;;
        *)
            dns=$(awk 'BEGIN{srand();} {print rand(), $0;}' dns4.txt | sort -k1,1n | head -n 1 | awk '{print $2}')
            dig $domain @$dns -t A +subnet=$subnet +short | grep -v ";" 2>/dev/null >> $domain/ipv4.txt
            cat $domain/ipv4.txt | sort |uniq > $domain/ipv4_u.txt
            mv $domain/ipv4_u.txt $domain/ipv4.txt
            ;;
        esac
    done
done

cp README_template.md README.md
for domain in $DOMAINS; do
    echo "[$domain]($domain)\n" >> README.md
done
