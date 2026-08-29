# ValkyriaOS

ValkyriaOS is an image built on top of Bluefin Linux image, thank to the [image-template](https://github.com/ublue-os/image-template) of [Universal Blue OS](https://universal-blue.org/).

So in short: ValkyriaOS is an atomic linux distro based on Bluefin which is based on rpm-ostree.

> [!WARNING]
> 
> **ValkyriaOS depends on my habits!**
> I created this distro to cover my half satisfaction with Bluefin, so I don't recommend daily driving it to anyone because the default software or tools installed may change with pass of time in case I want it.
> So keep in mind that I'll never care about any other user besides myself.

## What I've put into this distro

### Desktop
- **[Niri](https://github.com/niri-wm/niri)**: Scrollable Wayland tiling window manager.
- **[Dank Material Shell (DMS)](https://danklinux.com/)**: Material You desktop shell.
- **GDM**: Gnome Display Manager to switch between GNOME and Niri.
- **Wayland Portals**: Configured for screen and audio sharing on Discord and OBS.

### Apps and Tools
- **Ghostty**: As default terminal.
- **Zed**: As default code editor.
- **Mise**: Packages version manager for development (I want to stop with devboxes...).
- **Chezmoi**: Dotfiles manager with auto-sync from [gyratina/dotfiles](https://github.com/gyratina/dotfiles) at login.
- **GitHub CLI (`gh`)**.
- **NordVPN**: CLI + GUI with daemon and user permissions.
- [**Spotatui**](https://github.com/LargeModGames/spotatui).

### Terminal Shell
- **Zsh**: Default user shell.
- **Starship**: As default prompt set from Bluefin original image.
- **Zoxide**: A better `cd`.
- **Eza**: A better `ls`.
- **Plugins**: zsh-autosuggestions and zsh-syntax-highlighting.

### Look
- **CommitMonoGyratina**: Custom monospace font (size 16, weight 450) generated from [CommitMono](https://commitmono.com/).
- [**McMojave Cursors**](https://github.com/vinceliuice/McMojave-cursors): Default cursor theme.
- **Keyboard Layouts**: Italian and US(alt.intl.) with `Mod+Space` switch in Niri.

### Gaming and Flatpaks
- **Codecs**: RPM Fusion Free/Nonfree (full FFmpeg, x264, OBS plugins).
- **Debloat**: Removed stock Firefox, Thunderbird and Alacritty from Niri installation.
- **MangoHUD**.
- **58 Flatpaks**: Declaratively installed on first boot:
  - `app.zen_browser.zen`
  - `be.alexandervanhee.gradia`
  - `com.discordapp.Discord`
  - `com.github.PintaProject.Pinta`
  - `com.github.johnfactotum.Foliate`
  - `com.github.tchx84.Flatseal`
  - `com.mattjakeman.ExtensionManager`
  - `com.modrinth.ModrinthApp`
  - `com.ranfdev.DistroShelf`
  - `com.valvesoftware.Steam`
  - `de.leopoldluley.Clapgrep`
  - `info.febvre.Komikku`
  - `io.github.Querz.mcaselector`
  - `io.github.diegopvlk.Cine`
  - `io.github.finefindus.Hieroglyphic`
  - `io.github.flattool.Ignition`
  - `io.github.flattool.Warehouse`
  - `io.github.getnf.embellish`
  - `io.github.kolunmi.Bazaar`
  - `io.github.radiolamp.mangojuice`
  - `io.github.sugarycandybar.Hosty`
  - `io.gitlab.adhami3310.Impression`
  - `io.missioncenter.MissionCenter`
  - `io.podman_desktop.PodmanDesktop`
  - `it.mijorus.gearlever`
  - `md.obsidian.Obsidian`
  - `me.iepure.devtoolbox`
  - `net.nokyan.Resources`
  - `nl.emphisia.icon`
  - `org.gnome.Calculator`
  - `org.gnome.Calendar`
  - `org.gnome.Characters`
  - `org.gnome.Connections`
  - `org.gnome.Contacts`
  - `org.gnome.Decibels`
  - `org.gnome.DejaDup`
  - `org.gnome.FileRoller`
  - `org.gnome.Firmware`
  - `org.gnome.Logs`
  - `org.gnome.Loupe`
  - `org.gnome.Maps`
  - `org.gnome.NautilusPreviewer`
  - `org.gnome.Papers`
  - `org.gnome.Showtime`
  - `org.gnome.SimpleScan`
  - `org.gnome.Snapshot`
  - `org.gnome.TextEditor`
  - `org.gnome.Weather`
  - `org.gnome.baobab`
  - `org.gnome.clocks`
  - `org.gnome.font-viewer`
  - `org.localsend.localsend_app`
  - `org.onlyoffice.desktopeditors`
  - `org.pulseaudio.pavucontrol`
  - `org.telegram.desktop`
  - `org.videolan.VLC`
  - `org.freedesktop.Platform.VulkanLayer.MangoHud`
  - `page.tesk.Refine`

---

## Special Thanks
- **[morrolinux](https://www.youtube.com/@morrolinux)'s image: [morros](https://github.com/morrolinux/morros)** - I used it as ispiration to learn how to build my image, mainly because it included parts of my current configuration that I used as a starting point, and because his video introduced me to the ublue template.
- **Gemini 3.7 Flash** - I already imagine someone calling me a vibe coder lol, but that's not true. For sure without AI it would have taken sooo much longer to me to figure out how to build some things, but I used AI with two main goals: Building the perfect distro for my habits but also learning something new and understanding how and why it work. I truly believe that AI can be a powerful tool for every human being, if used to satisfy our curiosity and thirst for knowledge, but with a pinch of mistrust due to the possibility of hallucinations.
