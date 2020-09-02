#!/bin/sh
DomainName=www.hinet.net
DnsServer=8.8.8.8
for i in {1..30}; do dig @${DnsServer} ${DomainName} | grep ${DomainName}; done
