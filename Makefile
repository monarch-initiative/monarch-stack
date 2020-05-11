WGET = /usr/bin/wget --timestamping --no-verbose

BASE = .

MONARCH = https://archive.monarchinitiative.org/202003/

SOLR = $(BASE)/solr/solr.tgz

OWLSIM_FILES = \
	$(BASE)/owlsim/all.owl \
	$(BASE)/owlsim/owlsim.cache \
	$(BASE)/owlsim/ic-cache.owl

SCIGRAPH_DATA = \
	$(BASE)/scigraph-data/conf/scigraph-data.yaml \
        $(BASE)/scigraph-data/data/scigraph.tgz

SCIGRAPH_ONTOLOGY = \
	$(BASE)/scigraph-ontology/conf/scigraph-ontology.yaml \
	$(BASE)/scigraph-ontology/data/scigraph-ontology.tgz

MONARCH_UI = $(BASE)/monarch-ui/static-assets.tar.gz

SCIDATA_GRAPH = $(BASE)/scigraph-data/data/graph/

SCIONTOLOGY_GRAPH = $(BASE)/scigraph-ontology/data/graph/

SOLR_DATA = $(BASE)/solr/data/

all: $(SOLR) $(OWLSIM_FILES) $(SCIGRAPH_DATA) $(SCIGRAPH_ONTOLOGY) $(MONARCH_UI)

extract_all: extract_sciontology extract_scidata extract_solr extract_ui fetch_owlsim

extract_sciontology: $(SCIONTOLOGY_GRAPH)

extract_scidata: $(SCIDATA_GRAPH)

extract_solr: $(SOLR_DATA)

extract_ui: $(MONARCH_UI)
	tar -zxf monarch-ui/static-assets.tar.gz --no-same-owner --directory ./monarch-ui

fetch_owlsim: $(OWLSIM_FILES)

backup_previous:
	rm -rf $(BASE)/owlsim-old
	rm -rf $(BASE)/monarch-ui-old
	rm -rf $(BASE)/scigraph-ontology-old
	rm -rf $(BASE)/scigraph-data-old
	rm -rf $(BASE)/solr-old
	mv $(BASE)/owlsim/ $(BASE)/owlsim-old || true
	mv $(BASE)/monarch-ui/ $(BASE)/monarch-ui-old || true
	mv $(BASE)/scigraph-ontology/ $(BASE)/scigraph-ontology-old || true
	mv $(BASE)/scigraph-data/ $(BASE)/scigraph-data-old || true
	mv $(BASE)/solr/ $(BASE)/solr-old || true

$(BASE)/solr/:
	mkdir --parents $@

$(BASE)/owlsim/:
	mkdir --parents $@

$(BASE)/scigraph-data/data/:
	mkdir --parents $@

$(BASE)/scigraph-data/conf/:
	mkdir --parents $@

$(BASE)/scigraph-ontology/data/:
	mkdir --parents $@

$(BASE)/scigraph-ontology/conf/:
	mkdir --parents $@

$(BASE)/monarch-ui/:
	mkdir --parents $@

$(SCIGRAPH_DATA): | $(BASE)/scigraph-data/data/ $(BASE)/scigraph-data/conf/
	cd $(BASE)/scigraph-data/data && $(WGET) https://archive.monarchinitiative.org/latest/scigraph.tgz
	cd $(BASE)/scigraph-data/conf && $(WGET) https://archive.monarchinitiative.org/latest/conf/scigraph-data.yaml

$(SCIDATA_GRAPH): $(SCIGRAPH_DATA)
	tar -I pigz -xf $(BASE)/scigraph-data/data/scigraph.tgz --no-same-owner --directory $(BASE)/scigraph-data/data
	chgrp --recursive 14728 $(BASE)/scigraph-data
	chmod --recursive g+w $(BASE)/scigraph-data

$(SCIGRAPH_ONTOLOGY): | $(BASE)/scigraph-ontology/data/ $(BASE)/scigraph-ontology/conf/
	cd $(BASE)/scigraph-ontology/data && $(WGET) https://archive.monarchinitiative.org/latest/scigraph-ontology.tgz
	cd $(BASE)/scigraph-ontology/conf && $(WGET) https://archive.monarchinitiative.org/latest/conf/scigraph-ontology.yaml

$(SCIONTOLOGY_GRAPH): $(SCIGRAPH_ONTOLOGY)
	tar -I pigz -xf $(BASE)/scigraph-ontology/data/scigraph-ontology.tgz --no-same-owner --directory $(BASE)/scigraph-ontology/data
	chgrp --recursive 14728 $(BASE)/scigraph-ontology
	chmod --recursive g+w $(BASE)/scigraph-ontology

$(SOLR): $(BASE)/solr/
	cd $(BASE)/solr && $(WGET) https://archive.monarchinitiative.org/latest/solr.tgz

$(SOLR_DATA): $(SOLR)
	tar -I pigz -xf $(BASE)/solr/solr.tgz --no-same-owner --directory $(BASE)/solr
	chgrp --recursive 8983 $(BASE)/solr
	chmod --recursive g+w $(BASE)/solr

$(OWLSIM_FILES): | $(BASE)/owlsim/
	cd $(BASE)/owlsim && $(WGET) https://archive.monarchinitiative.org/latest/owlsim/all.owl
	cd $(BASE)/owlsim && $(WGET) https://archive.monarchinitiative.org/latest/owlsim/ic-cache.owl
	cd $(BASE)/owlsim && $(WGET) https://archive.monarchinitiative.org/latest/owlsim/owlsim.cache

$(MONARCH_UI): | $(BASE)/monarch-ui/
	cd $(BASE)/monarch-ui && $(WGET) https://github.com/monarch-initiative/monarch-ui/releases/download/v1.0.2/static-assets.tar.gz

$(BASE)/monarch-ui/dist:
	tar -I pigz -xf monarch-ui/static-assets.tar.gz --no-same-owner --directory $(BASE)/monarch-ui
