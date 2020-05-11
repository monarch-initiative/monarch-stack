#!/bin/sh

### Solr 6
# https://github.com/docker-solr/docker-solr/blob/master/Docker-FAQ.md#how-can-i-mount-a-host-directory-as-a-data-volume
# Recommends sudo chown 8983:8983 /home/docker-volumes/mysolr1, seeing if we can get around without using sudo
##########

docker pull monarchinitiative/gcc-pigz:10.1

docker run --workdir /usr/src/ -v `pwd`:/usr/src/ monarchinitiative/gcc-pigz:10.1  make extract_solr

docker pull solr:6.6-slim
docker run --restart=unless-stopped -d -v `pwd`/solr/data:/data -e SOLR_HOME=/data -p 8983:8983 solr:6.6-slim 

curl "localhost:8983/solr/golr/select?q=*:*&wt=json"


### Scigraph Data
#################

docker run --workdir /usr/src/ -v `pwd`:/usr/src/ monarchinitiative/gcc-pigz:10.1  make extract_scidata

docker pull monarchinitiative/scigraph:2.2

docker run --restart=unless-stopped -v `pwd`/scigraph-data/data:/data -v `pwd`/scigraph-data/conf:/scigraph/conf -d -p 9000:9000 --name scigraph-data monarchinitiative/scigraph:2.2 start-scigraph-service scigraph-data.yaml

curl "localhost:9000/scigraph/graph/HGNC%3A11027"


### Scigraph Ontology
#####################

docker run --workdir /usr/src/ -v `pwd`:/usr/src/ monarchinitiative/gcc-pigz:10.1  make extract_sciontology

docker run --restart=unless-stopped -v `pwd`/scigraph-ontology/data:/data -v `pwd`/scigraph-ontology/conf:/scigraph/conf -d -p 9090:9000 --name scigraph-ontology monarchinitiative/scigraph:2.2 start-scigraph-service scigraph-ontology.yaml

curl "localhost:9090/scigraph/graph/MONDO:0000001"

### Owlsim
##########

docker run --workdir /usr/src/ -v `pwd`:/usr/src/ monarchinitiative/gcc-pigz:10.1  make fetch_owlsim

docker pull monarchinitiative/owlsim:0.3.0

docker run -v `pwd`/owlsim:/data -p 9031:9031 -d monarchinitiative/owlsim:0.3.0 /bin/sh -c 'export OWLTOOLS_MEMORY=45G && owltools /data/all.owl --use-fsim  --sim-load-lcs-cache /data/owlsim.cache --sim-load-ic-cache /data/ic-cache.owl --start-sim-server -p 9031'

### Takes 12 minutes to start, see https://docs.docker.com/compose/startup-order/

./wait-for-owlsim.sh

### Biolink
###########


docker pull monarchinitiative/biolink-api:1.0.1

docker run -d -p 5000:5000 -v `pwd`/resources:/config monarchinitiative/biolink-api:1.0.1 start-server -k gevent --worker-connections 5 --bind 0.0.0.0:5000 wsgi:app

curl http://localhost:5000/api/bioentity/gene/NCBIGene%3A4750/diseases


### UI
##########

docker run --workdir /usr/src/ -v `pwd`:/usr/src/ monarchinitiative/gcc-pigz:10.1  make extract_ui

docker pull monarchinitiative/nginx:1.18.0

docker run -d -v `pwd`/monarch-ui/dist:/app -p 8181:80 monarchinitiative/nginx:1.18.0

curl localhost:8181

