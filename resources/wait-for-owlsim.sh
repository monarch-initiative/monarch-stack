#!/bin/bash
# wait-for-owlsim.sh

set -e

url="http://owlsim:9031/getAttributeInformationProfile"
categories="http://owlsim:9031/getAttributeInformationProfile?r=HP:0000924&r=HP:0000707&r=HP:0000152&r=HP:0001574&r=HP:0000478&r=HP:0001626&r=HP:0001939&r=HP:0000119&r=HP:0025031&r=HP:0002664&r=HP:0001871&r=HP:0002715&r=HP:0000818&r=HP:0003011&r=HP:0002086&r=HP:0000598&r=HP:0003549&r=HP:0001197&r=HP:0001507&r=HP:0000769"

until [ $(curl --write-out %{http_code} --silent --output /dev/null ${url}) -eq 200 ] ; do
  >&2 echo "owlsim loading"
  sleep 15
done

curl ${categories}

cmd="$@"
exec $cmd
