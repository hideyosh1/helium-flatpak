# Helium Flatpak

This folder contains a Flatpak manifest to package the latest prebuilt [Helium Browser](https://github.com/imputnet/helium) binary
from the official [GitHub releases](https://github.com/imputnet/helium-linux/releases).

## Build and Install

You can build and install the Flatpak locally:

```bash
flatpak-builder --user --install --force-clean build-dir com.imputnet.Helium.yml
flatpak run com.imputnet.Helium
```

## Install from repo
Alternatively, you can install Helium directly from the Flatpak repository:

```bash
flatpak remote-add --user --no-gpg-verify helium-repo https://shyvortex.github.io/helium-flatpak/
flatpak install helium-repo com.imputnet.Helium
flatpak run com.imputnet.Helium
```

## Troubleshooting

### Cloudflare Verification
Some of Helium's default flags are incompatible with Cloudflare's browser verification checks.  
If you are unable to authenticate on sites using Cloudflare, you must disable these specific settings.  
Navigate to `helium://flags`, then search for and disable the following flags:  

<img width="814" height="225" alt="Screenshot 2025-12-19 103420" src="https://github.com/user-attachments/assets/0182667d-4214-4372-97d2-9ca68ff2e8f8" />
