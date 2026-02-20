#!/usr/bin/env sh
flatpak-builder --force-clean --repo=repo build-dir net.imput.helium.yml       # rebuild
flatpak build-bundle ~/dev/helium-flatpak/repo helium.flatpak net.imput.helium # build bundle
