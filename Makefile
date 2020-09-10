#!/usr/bin/make -f

PACKAGE_NAME := $(shell dpkg-parsechangelog -ldebian/changelog | grep '^Source: ' | cut -f2 -d' ')
PACKAGE_VERSION := $(shell dpkg-parsechangelog -ldebian/changelog | grep '^Version: ' | cut -f2 -d' ')


.DEFAULT: build

all: build
build:
	@echo ok

clean-releases: debian/control
	rm -vf ../$(PACKAGE_NAME)_*.tar.* \
		../$(PACKAGE_NAME)_*.dsc \
		../$(PACKAGE_NAME)_*_*.build \
		../$(PACKAGE_NAME)_*_*.buildinfo \
		../$(PACKAGE_NAME)_*_*.changes
	for pkg in $(shell dh_listpackages); do rm -vf ../$${pkg}_*_*.deb; done

build-release:
	debuild -i -I

build-local:
	dch -l~test "Local test build: $(shell date)"
	debuild -i -I -uc -us

upload: build-release
	@echo Uploading changes to the remote, see ~/.dupload.conf
	for changes in ../$(PACKAGE_NAME)_$(PACKAGE_VERSION)_*.changes; do \
		dupload -t deb.n-1.fi $$changes ; \
	done


.PHONY: all build build-release upload
