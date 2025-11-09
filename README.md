# Helium Flatpak

This folder contains a Flatpak manifest to package the latest prebuilt Helium Browser binary
from the official GitHub releases.

## Build and Install

```bash
flatpak-builder --user --install --force-clean build-dir com.imputnet.Helium.yml
flatpak run com.imputnet.Helium
```

## Updating

To update to a newer release:
1. Update the manifest via [External Data Checker](https://github.com/flathub-infra/flatpak-external-data-checker).
```bash
flatpak run org.flathub.flatpak-external-data-checker --update com.imputnet.Helium.yml
```
2. Rebuild with `flatpak-builder --install`.
