# Magic Set Editor — Linux Package

An unofficial Linux build and installer for [Magic Set Editor 2](https://github.com/haganbmj/MagicSetEditor2), a program for designing custom trading cards.

This package builds MSE from the [haganbmj fork](https://github.com/haganbmj/MagicSetEditor2) and provides a simple install script with optional template pack downloads from [MagicSetEditorPacks](https://github.com/MagicSetEditorPacks).

---

## Installation

### Requirements
- A Linux distro with `git`, `wget`, and `fc-cache` available
- An internet connection (for template pack download during install)

### Steps

1. Download the latest `MagicSetEditor-linux.tar.gz` from the [Releases](../../releases) page
2. Extract it:

        tar -xzf MagicSetEditor-linux.tar.gz
        cd mse-package

3. Run the install script:

        ./install.sh

4. Follow the prompt to choose a template pack:
   - **Basic M15** — Beginner-friendly, small download (~50MB)
   - **M15** — All M15-style templates (~200MB)
   - **Full MTG** — Nearly all public MTG templates (~600MB)
   - **Full Non-MTG** — Non-Magic card game templates (~300MB)
   - **Full MTG + Non-MTG** — Everything
   - **None** — Skip (you can install templates later)

MSE will be available from your app launcher or by typing `magicseteditor` in a terminal. If the terminal command isn't found, add `~/.local/bin` to your PATH:

    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    source ~/.bashrc

---

## Uninstallation

From the extracted `mse-package/` directory:

    ./uninstall.sh

This removes the binary, app launcher entry, and fonts. It will ask before removing `~/.magicseteditor` so your saved card sets are not deleted without confirmation.

---

## Files Installed

| Path | Contents |
|---|---|
| `~/.local/bin/magicseteditor` | MSE executable |
| `~/.local/share/applications/magicseteditor.desktop` | App launcher entry |
| `~/.local/share/fonts/` | MTG fonts |
| `~/.magicseteditor/data/` | MSE game data and templates |
| `~/.magicseteditor/resource/` | MSE UI resources |

---

## Runtime Dependencies

The MSE binary dynamically links against several libraries that must be present on your system. Most desktop Linux installs will already have these, but minimal or container-based installs may not.

| Library | Purpose | Fedora | Debian/Ubuntu | Arch | openSUSE |
|---|---|---|---|---|---|
| wxGTK 3.x | GUI toolkit | `wxGTK` | `libwxgtk3.2-0` | `wxwidgets-gtk3` | `wxWidgets-3_2` |
| OpenGL / GLU | Rendering | `mesa-libGL` `mesa-libGLU` | `libgl1` `libglu1-mesa` | `mesa` `glu` | `Mesa-libGL1` `Mesa-libGLU1` |
| Hunspell | Spell checking | `hunspell` | `libhunspell-1.7-0` | `hunspell` | `libhunspell-1_7-0` |
| libstdc++ | C++ runtime | pre-installed | pre-installed | pre-installed | pre-installed |

If MSE fails to launch, check for missing libraries with:

    ldd ~/.local/bin/magicseteditor | grep "not found"

> **Note:** The prebuilt binary is currently only compiled against Fedora 43. Because glibc is forwards-compatible but not backwards-compatible, the binary may fail on older distros (Debian 11, Ubuntu 20.04) with a `GLIBC_X.XX not found` error. If you hit this, build from source on your own system using the instructions below. Pre-build binaries for other common distributions will be packaged alongside the install for future releases. 


## Building from Source

To rebuild the package yourself:

### Dependencies

<details><summary>Fedora</summary>

    sudo dnf install gcc-c++ cmake make git wget unzip wxGTK-devel boost-devel hunspell-devel

</details>
<details><summary>Debian/Ubuntu</summary>

    sudo apt install g++ cmake make git wget unzip libwxgtk3.2-dev libboost-dev libhunspell-dev

</details>
<details><summary>Arch/Manjaro</summary>

    sudo pacman -S gcc cmake make git wget unzip wxwidgets-gtk3 boost hunspell

</details>
<details><summary>openSUSE</summary>

    sudo zypper install gcc-c++ cmake make git wget unzip wxWidgets-devel boost-devel hunspell-devel

</details>

### Build

    git clone https://github.com/astralacuna/mse-linux-package.git
    cd mse-linux-package
    ./build.sh

The script clones the upstream source, builds it, downloads the base data files, and assembles a fresh release package under `~/build/mse/`. The release tarball is at `~/build/mse/MagicSetEditor-linux.tar.gz`.

> **Immutable distros (Bazzite, Silverblue, etc.):** Running `build.sh` requires build dependencies (`wxGTK-devel`, `mesa-libGLU-devel`, etc.) that are not available on the host image of immutable distros. Building from source is not supported on these systems. Use the prebuilt release tarball from the [Releases](../../releases) page instead — the installer itself works fine since all paths are in `~/.local/`.

---

## Licensing

- **Magic Set Editor 2** is licensed under [GPL v2](https://github.com/haganbmj/MagicSetEditor2/blob/master/LICENSE).
- Template packs are provided by [MagicSetEditorPacks](https://github.com/MagicSetEditorPacks) and downloaded directly from their repositories during install.
- This packaging script is also released under GPL v2.

This is an unofficial project and is not affiliated with the original MSE developers.
