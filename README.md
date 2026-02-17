# Helium Flatpak

This repository contains the [Flatpak](https://flatpak.org/) manifest for **Helium**, a private, fast, and honest web browser based on Ungoogled Chromium.

It wraps the official prebuilt binaries from the [Helium Linux project](https://github.com/imputnet/helium-linux) into a sandboxed Flatpak environment, ensuring it runs securely and consistently across different Linux distributions.

---

## Installation (Recommended)

The easiest way to install Helium is using the standalone bundle. This bypasses the need for manual repositories and works on any system with Flatpak installed.

1.  **Download** the latest `.flatpak` bundle from the [**Releases Page**](https://github.com/ShyVortex/helium-flatpak/releases).
2.  **Install** it via the command line:

    ```bash
    flatpak install helium-[VERSION].flatpak
    ```

    *Note: On many distributions (like Fedora Silverblue, SteamOS, or Ubuntu), you can simply double-click the downloaded file to install it via your Software Center.*

---

## Building from Source

If you want to build the package yourself or contribute to the manifest, follow these steps.

### Prerequisites
Ensure you have `flatpak` and `flatpak-builder` installed. You also need the Flathub repository enabled to download the Freedesktop SDK/Runtime (version 25.08).

```bash
flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
```

### Build & Install
Run the following command in the root of this repository. This will download the binary, build the sandbox, and install it to your user directory.

```bash
flatpak-builder --user --install --force-clean build-dir com.imputnet.Helium.yml
```

---

## Running the App

Once installed (via bundle or local build), you can launch Helium from your application menu or via the terminal:

```bash
flatpak run com.imputnet.Helium
```

---

## Uninstallation

To remove Helium and its data:

```bash
flatpak uninstall com.imputnet.Helium
# Optional: Remove app data
rm -rf ~/.var/app/com.imputnet.Helium
```

---

**Disclaimer:** This is an unofficial packaging project. For issues related to the browser itself, please refer to the [upstream repository](https://github.com/imputnet/helium). For packaging issues, feel free to open an issue here.
