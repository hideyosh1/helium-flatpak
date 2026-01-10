#!/usr/bin/env sh
flatpak-builder --force-clean --repo=repo build-dir com.imputnet.Helium.yml  # rebuild
flatpak build-bundle ~/dev/helium-flatpak helium.flatpak com.imputnet.Helium # build bundle
