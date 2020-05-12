MONARCH = https://archive.monarchinitiative.org/202003/

BASE = ./data
MONARCH_GID = 14728
SOLR_GID = 8983


WGET = /usr/bin/wget --timestamping --no-verbose

SOLR = $(BASE)/solr.tgz

OWLSIM_FILES = \
	$(BASE)/owlsim/all.owl \
	$(BASE)/owlsim/owlsim.cache \
	$(BASE)/owlsim/ic-cache.owl

SCIGRAPH_DATA = $(BASE)/scigraph.tgz

SCIGRAPH_ONTOLOGY = $(BASE)/scigraph-ontology.tgz

SCIDATA_CONF = $(BASE)/scigraph-data/conf/scigraph-data.yaml

SCIONTOLOGY_CONF = $(BASE)/scigraph-ontology/conf/scigraph-ontology.yaml

MONARCH_UI = $(BASE)/static-assets.tar.gz

SCIDATA_GRAPH = $(BASE)/scigraph-data/graph

SCIONTOLOGY_GRAPH = $(BASE)/scigraph-ontology/graph

SOLR_DATA = $(BASE)/solr/data

MONARCH_UI_DIST = $(BASE)/monarch-ui/dist

all: $(SOLR) $(OWLSIM_FILES) $(SCIGRAPH_DATA) $(SCIGRAPH_ONTOLOGY) $(MONARCH_UI)

extract_all: extract_sciontology extract_scidata extract_solr extract_ui extract_owlsim

extract_sciontology: $(SCIONTOLOGY_GRAPH) $(SCIONTOLOGY_CONF)

extract_scidata: $(SCIDATA_GRAPH) $(SCIDATA_CONF)

extract_solr: $(SOLR_DATA)

extract_ui: $(MONARCH_UI_DIST)

extract_owlsim: $(OWLSIM_FILES)

$(SCIGRAPH_DATA):
	cd $(BASE) && $(WGET) https://archive.monarchinitiative.org/latest/scigraph.tgz
	chgrp $(MONARCH_GID) $@

$(SCIGRAPH_ONTOLOGY):
	cd $(BASE) && $(WGET) https://archive.monarchinitiative.org/latest/scigraph-ontology.tgz
	chgrp $(MONARCH_GID) $@

$(SOLR):
	cd $(BASE) && $(WGET) https://archive.monarchinitiative.org/latest/solr.tgz
	chgrp $(MONARCH_GID) $@

$(MONARCH_UI):
	cd $(BASE) && $(WGET) https://github.com/monarch-initiative/monarch-ui/releases/download/v1.0.2/static-assets.tar.gz
	chgrp $(MONARCH_GID) $@

$(OWLSIM_FILES):
	mkdir $(BASE)/owlsim-new
	cd $(BASE)/owlsim-new && $(WGET) https://archive.monarchinitiative.org/latest/owlsim/all.owl
	cd $(BASE)/owlsim-new && $(WGET) https://archive.monarchinitiative.org/latest/owlsim/ic-cache.owl
	cd $(BASE)/owlsim-new && $(WGET) https://archive.monarchinitiative.org/latest/owlsim/owlsim.cache
	chgrp --recursive $(MONARCH_GID) $(BASE)/owlsim-new
	rm -rf $(BASE)/owlsim-old
	mv $(BASE)/owlsim $(BASE)/owlsim-old || true
	mv $(BASE)/owlsim-new $(BASE)/owlsim

$(SCIDATA_GRAPH): $(SCIGRAPH_DATA)
	mkdir --parents $(BASE)/scigraph-data-new/data
	tar -I pigz -xf $(SCIGRAPH_DATA) --no-same-owner --directory $(BASE)/scigraph-data-new/data
	chgrp --recursive $(MONARCH_GID) $(BASE)/scigraph-data-new
	chmod --recursive g+w $(BASE)/scigraph-data-new
	rm -rf $(BASE)/scigraph-data-old
	mv $(BASE)/scigraph-data $(BASE)/scigraph-data-old || true
	mv $(BASE)/scigraph-data-new $(BASE)/scigraph-data

$(SCIONTOLOGY_GRAPH): $(SCIGRAPH_ONTOLOGY)
	mkdir --parents $(BASE)/scigraph-ontology-new/data
	tar -I pigz -xf $(SCIGRAPH_ONTOLOGY) --no-same-owner --directory $(BASE)/scigraph-ontology-new/data
	chgrp --recursive $(MONARCH_GID) $(BASE)/scigraph-ontology-new
	chmod --recursive g+w $(BASE)/scigraph-ontology-new
	rm -rf $(BASE)/scigraph-ontology-old
	mv $(BASE)/scigraph-ontology $(BASE)/scigraph-ontology-old || true
	mv $(BASE)/scigraph-ontology-new $(BASE)/scigraph-ontology

$(SCIDATA_CONF): | $(SCIDATA_GRAPH)
	mkdir --parents $(BASE)/scigraph-data/conf
	cd $(BASE)/scigraph-data/conf && $(WGET) https://archive.monarchinitiative.org/latest/conf/scigraph-data.yaml
	chgrp --recursive $(MONARCH_GID) $(BASE)/scigraph-data/conf

$(SCIONTOLOGY_CONF): | $(SCIONTOLOGY_GRAPH)
	mkdir --parents $(BASE)/scigraph-ontology/conf
	cd $(BASE)/scigraph-ontology/conf && $(WGET) https://archive.monarchinitiative.org/latest/conf/scigraph-ontology.yaml
	chgrp --recursive $(MONARCH_GID) $(BASE)/scigraph-ontology/conf

$(SOLR_DATA): $(SOLR)
	mkdir $(BASE)/solr-new
	tar -I pigz -xf $(SOLR) --no-same-owner --directory $(BASE)/solr-new
	chgrp --recursive $(SOLR_GID) $(BASE)/solr-new
	chmod --recursive g+w $(BASE)/solr-new
	rm -rf $(BASE)/solr-old
	mv $(BASE)/solr $(BASE)/solr-old || true
	mv $(BASE)/solr-new $(BASE)/solr

$(MONARCH_UI_DIST): $(MONARCH_UI)
	mkdir $(BASE)/monarch-ui-new
	tar -I pigz -xf $(MONARCH_UI) --no-same-owner --directory $(BASE)/monarch-ui-new
	chgrp --recursive $(MONARCH_GID) $(BASE)/monarch-ui-new
	rm -rf $(BASE)/monarch-ui-old
	mv $(BASE)/monarch-ui $(BASE)/monarch-ui-old || true
	mv $(BASE)/monarch-ui-new $(BASE)/monarch-ui
