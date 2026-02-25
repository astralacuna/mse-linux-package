# Magic Set Editor — Linux Package

An unofficial Linux build and installer for [Magic Set Editor 2](https://github.com/G-e-n-e-v-e-n-s-i-S/MagicSetEditor2), a program for designing custom trading cards.

This package builds MSE from the [G-e-n-e-v-e-n-s-i-S fork](https://github.com/G-e-n-e-v-e-n-s-i-S/MagicSetEditor2) and provides a simple install script with optional template pack downloads from [MagicSetEditorPacks](https://github.com/MagicSetEditorPacks).

---

## Installation

### Requirements
- A Linux distro with `git` and `fc-cache` available
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

This removes the binary, bundled libraries, app launcher entry, and fonts. It will ask before removing `~/.magicseteditor` so your saved card sets are not deleted without confirmation.

---

## Files Installed

| Path | Contents |
|---|---|
| `~/.local/bin/magicseteditor` | MSE executable |
| `~/.local/share/magicseteditor/lib/` | Bundled runtime libraries |
| `~/.local/share/magicseteditor/resource/` | MSE UI resources |
| `~/.local/share/applications/magicseteditor.desktop` | App launcher entry |
| `~/.local/share/fonts/` | MTG fonts |
| `~/.magicseteditor/data/` | MSE game data and templates |
| `~/.magicseteditor/resource/` | MSE UI resources (fallback) |

---

## Runtime Dependencies

The MSE binary bundles its most version-sensitive dependencies (wxWidgets, hunspell, GLU) so it should work out of the box on most desktop Linux installs. The one library that cannot safely be bundled is `libGL`, which is driver-specific and must come from your system.

| Library | Purpose | Fedora | Debian/Ubuntu | Arch | openSUSE |
|---|---|---|---|---|---|
| libGL | Rendering | `mesa-libGL` | `libgl1` | `mesa` | `Mesa-libGL1` |

If MSE fails to launch, check for missing libraries with:

    ldd ~/.local/bin/magicseteditor | grep "not found"

> **Note:** The prebuilt binary was compiled on Debian 12 (glibc 2.36). It may fail on older distros such as Debian 11 or Ubuntu 20.04 with a `GLIBC_X.XX not found` error. If you hit this, build from source on your own system using the instructions below.

---

## Building from Source

To rebuild the package yourself, you need **Docker** installed. The build runs inside a Debian 12 container — no other build dependencies needed on your host.

### Build

    git clone https://github.com/astralacuna/mse-linux-package.git
    cd mse-linux-package
    ./build.sh

On first run this builds the Docker image (~1.5–2GB), which includes compiling wxWidgets 3.3.1 from source. This takes 10–20 minutes but is cached for all subsequent runs. The assembled package lands in `~/build/mse/mse-package/` and the release tarball at `~/build/mse/MagicSetEditor-linux.tar.gz`.

### Distro Build Dependencies

Docker is the only host dependency. All other build dependencies are handled inside the container.

<details><summary>Installing Docker on Fedora</summary>

    sudo dnf install docker
    sudo systemctl enable --now docker
    sudo usermod -aG docker $USER

</details>
<details><summary>Installing Docker on Debian/Ubuntu</summary>

    sudo apt install docker.io
    sudo systemctl enable --now docker
    sudo usermod -aG docker $USER

</details>
<details><summary>Installing Docker on Arch/Manjaro</summary>

    sudo pacman -S docker
    sudo systemctl enable --now docker
    sudo usermod -aG docker $USER

</details>
<details><summary>Installing Docker on openSUSE</summary>

    sudo zypper install docker
    sudo systemctl enable --now docker
    sudo usermod -aG docker $USER

</details>

> **Immutable distros (Bazzite, Silverblue, etc.):** Docker may not be available or may require layering on immutable distros. Use the prebuilt release tarball from the [Releases](../../releases) page instead — the installer itself works fine since all paths are in `~/.local/`.

---

## Licensing

- **Magic Set Editor 2** is licensed under [GPL v2](https://github.com/G-e-n-e-v-e-n-s-i-S/MagicSetEditor2/blob/master/LICENSE).
- Template packs are provided by [MagicSetEditorPacks](https://github.com/MagicSetEditorPacks) and downloaded directly from their repositories during install.
- This packaging script is also released under GPL v2.

This is an unofficial project and is not affiliated with the original MSE developers.
