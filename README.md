# Helium Flatpak

This folder contains a Flatpak manifest to package the latest prebuilt Helium Browser binary
from the official GitHub releases.

## Build and Install

```bash
flatpak-builder --user --install --force-clean build-dir computer.helium.Helium.yml
flatpak run computer.helium.Helium
```

## Updating

To update to a newer release:
1. Update the manifest via [External Data Checker](https://github.com/flathub-infra/flatpak-external-data-checker).
```bash
flatpak run org.flathub.flatpak-external-data-checker --update computer.helium.Helium.yml
```
2. Rebuild with `flatpak-builder --install`.
