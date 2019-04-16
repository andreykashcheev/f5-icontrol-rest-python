PROJECT_DIR := $(shell pwd)
VERSION := $(shell cat VERSION|tr -d '\n';)
RELEASE := $(shell cat RELEASE|tr -d '\n';)

default: source


# Clouddocs related section

# You can set these variables from the command line.
SPHINXOPTS    =
SPHINXBUILD   = sphinx-build
PAPER         =
BUILDDIR      = docs/_build

# Internal variables.
PAPEROPT_a4     = -D latex_paper_size=a4
PAPEROPT_letter = -D latex_paper_size=letter
ALLSPHINXOPTS   = -d $(BUILDDIR)/doctrees $(PAPEROPT_$(PAPER)) $(SPHINXOPTS) ./docs
# the i18n builder cannot share the environment and doctrees with the others
I18NSPHINXOPTS  = $(PAPEROPT_$(PAPER)) $(SPHINXOPTS) ./docs




.PHONY: html
html:
	$(SPHINXBUILD) -b html $(ALLSPHINXOPTS) $(BUILDDIR)/html
	@echo
	@echo "Build finished. The HTML pages are in $(BUILDDIR)/html."


# build live preview docs locally
.PHONY: livehtml
livehtml:
	@echo "Running autobuild. View live edits at:"
	@echo "  http://127.0.0.1:8000/index.html"
	@echo ""
	sphinx-autobuild --host 0.0.0.0 -b html $(ALLSPHINXOPTS) $(BUILDDIR)/html



.PHONY: linkcheck
linkcheck:
	$(SPHINXBUILD) -b linkcheck $(ALLSPHINXOPTS) $(BUILDDIR)/linkcheck
	@echo
	@echo "Link check complete; look for any errors in the above output " \
	      "or in $(BUILDDIR)/linkcheck/output.txt."

# Build live preview docs in a docker container
.PHONY: docker-preview
docker-preview:
	rm -rf ./_build
	DOCKER_RUN_ARGS="-p 127.0.0.1:8000:8000" ./scripts/docker-docs.sh \
	  make livehtml

# run quality tests in a docker container
.PHONY: docker-test
docker-test:
	chmod -R 755 script
	rm -rf ./_build
	./script/test-docs.sh

# one-time html build in a docker container
.PHONY: docker-html
docker-html:
	chmod -R 755 script
	rm -rf ./_build
	./script/docker-docs.sh make html


# end of clouddocs section

source:
	(python setup.py sdist; \
	rm -rf MANIFEST; \
	)

clean: clean-debs clean-rpms clean-source
	rm -rf *.egg-info *~

clean-debs:
	find . -name "*.pyc" -exec rm -rf {} \;
	rm -f MANIFEST
	rm -f build/f5-bigip-common_*.deb
	( \
	rm -rf deb_dist; \
	rm -rf build; \
	)

clean-rpms:
	find . -name "*.pyc" -exec rm -rf {} \;
	rm -f MANIFEST
	rm -rf f5-bigip-common*
	rm -f build/f5-bigip-common-*.rpm
	( \
	rm -rf dist; \
	rm -rf build; \
	)

clean-source:
	rm -rf build/*.tar.gz
	rm -rf common/*.tar.gz
	rm -rf common/dist
