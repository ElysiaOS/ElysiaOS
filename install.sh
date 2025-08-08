#!/bin/bash

set -e

# === Confirm with Y/N ===
if [ -t 0 ]; then
    # Interactive shell, show prompt
    read -rp "Are you sure you want to run ElysiaOS installation (this will modify home directory folder before running make sure you backup important stuff or reading script)...? [y/N]: " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Aborted by user."
        exit 1
    fi
else
    # Force prompt by opening /dev/tty (the actual terminal)
    if confirm=$(</dev/tty read -rp "Are you sure you want to run ElysiaOS installation (this will modify home directory folder before running make sure you backup important stuff or reading script)...? [y/N]: " confirm && echo "$confirm"); then
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            echo "Aborted by user."
            exit 1
        fi
    else
        echo "[!] Unable to read from /dev/tty. Assuming 'no'."
        exit 1
    fi
fi

# === Cache sudo credentials to reduce password prompts ===
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# === Add ElysiaOS Repo ===
echo "[INFO] Checking for ElysiaOS repository in pacman.conf..."
if ! grep -q '^\[elysiaos-repo\]' /etc/pacman.conf; then
    echo "[INFO] Adding ElysiaOS repository to pacman.conf..."
    sudo awk '/^\[core\]/{print; getline; print; print "\n[elysiaos-repo]\nSigLevel = Optional DatabaseOptional\nServer = https://raw.githubusercontent.com/ElysiaOS/elysiaos-repo/refs/heads/main/$arch"; next}1' /etc/pacman.conf > /etc/pacman.conf.tmp && mv /etc/pacman.conf.tmp /etc/pacman.conf
else
    echo "[INFO] ElysiaOS repository already exists, skipping."
fi

sudo pacman -Syyy --noconfirm || true

# === ASCII Art Banner ===
cat << "EOF"
                    ░╦╦▒▒╛``  `
                  µ░▒╩`  «═ª ,     ,╦H
                ⌐▒░ª  1▒╩=~ ` `+═╩ªª╩░
              å ▒▒ ,ª 1░   å    `,   ░╕
           `▒▒░ ▒ ╒   ª▒   ╕     å  ¿░,¿==,,,,,
            ╦░░   `,⌐ß≈ª`  ¬▒  ⌐ ╧``ªÖ`    `░░░ª
           ªª`,⌐╦▒ª` .       ⌐       ╒    ⌐▒╩
            "╧Ñ▒░▒~   ~.     .╒,  ,╦▒` Ñ░
           ,░▒╦÷ `ª╩╩╩═╦,ª╩▒▒░▒ª░░╩ª    `▒▒
           `ª░░░╦ ▒  ,╫╩       ▒░▒▒,     `░▒  ª
             ª▒░░µ`º 1░        ░H  ╚▒▒╦╦╦▒░░▒`
               ,"ª~  ▒░     .╦▒▒ª     "ª╨Ñ▒░░▒
                ª▒╦¿ ░░   ,╦░▒²   ,÷=`,.,ß= `ª=
                 1╩~,░░░░░░╩` ``   ,¿⌐▒░╩`
                    ╒░░░▒ª ┌▒░░░░░░╩╨``
                    ╒░╩"        `╧▒
                    ª
EOF
echo
echo "Welcome to the ElysiaOS Auto-Installer"
echo


# === Check for yay ===
echo "[+] Checking for yay..."
if ! command -v yay &>/dev/null; then
    echo "[!] yay not found. Installing yay..."
    sudo pacman -S --needed --noconfirm git base-devel
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    pushd /tmp/yay >/dev/null
    makepkg -si --noconfirm
    popd >/dev/null
    rm -rf /tmp/yay
else
    echo "[✓] yay is already installed."
fi

# === Package Install Section ===
echo "[+] Installing packages with yay..."

PACKAGES=(
  waybar thunar hyprland starship discord krita
  eww wlogout swww kitty swayosd btop fastfetch
  hyprcursor hyprgraphics hypridle hyprland-qt-support
  hyprlock hyprpicker hyprutils hyprswitch
  xdg-desktop-portal-hyprland xdg-desktop-portal-gnome gnome-text-editor
  xdg-desktop-portal xfce4-settings xfce4-taskmanager
  gsettings-desktop-schemas gsettings-system-schemas
  qt5-base qt5-multimedia qt5-svg qt5-wayland qt5ct
  qt6-base qt6-wayland qt6ct noto-fonts downgrade
  visual-studio-code-bin sublime-text-4 grim xclip wl-clipboard
  libnotify clipnotify copyq playerctl brightnessctl
  zip libzip file-roller unzip thunar-archive-plugin
  sddm-eucalyptus-drop swaylock-effects auto-cpufreq python
  python-cairo python-installer python-numpy python-pillow python-pip
  python-psutil python-pyqt6 python-pyqt5 ttf-jetbrains-mono-nerd
  gpu-screen-recorder gpu-screen-recorder-ui gpu-screen-recorder-notification
  python-pyqt5-webengine python-pyqt6-sip python-pyqt5-sip python-tqdm
  gpu-screen-recorder-notification playerctl xkb-switch brightnessctl
  pipewire-pulse ttf-jetbrains-mono swaync-elysiaos granite
  qimgv sxiv granite7 libhandy python-pypresence
  xorg-xhost polkit-gnome polkit-qt6 gnome-terminal
  ffmpegthumbnailer tumbler slurp bc coreutils dmenu
  ttf-dejavu ttf-ubuntu-font-family ttf-doulos-sil ttf-hanazono
  ttf-sazanami ttf-baekmuk ttf-arphic-uming
  noto-fonts-cjk noto-fonts-emoji ttf-firacode-nerd
  fcitx5 fcitx5-configtool fcitx5-mozc mpv jq
  ffmpeg gst-libav qt6-multimedia-ffmpeg gparted
  elysia-updater-elysiaos elysia-settings-elysiaos
  signet-workspaces-elysiaos keybinds-elysiaos
)

yay -Syyy --noconfirm --needed "${PACKAGES[@]}" || {
  echo "[!] Conflict detected. Retrying with overwrite..."
  yay -Syyy --noconfirm --needed --overwrite '*' "${PACKAGES[@]}"
}

# === Install Floorp Browser ===
echo "[+] Downloading Floorp browser..."

FLOORP_URL="https://github.com/Floorp-Projects/Floorp/releases/download/v12.0.14/floorp-linux-amd64.tar.xz"
FLOORP_ARCHIVE="floorp-linux-amd64.tar.xz"

# Download
curl -L "$FLOORP_URL" -o "$FLOORP_ARCHIVE"

# Verify download success
if [[ ! -f "$FLOORP_ARCHIVE" ]]; then
  echo "[✗] Failed to download Floorp."
  exit 1
fi

# Extract
echo "[+] Extracting Floorp..."
tar -xf "$FLOORP_ARCHIVE"

# Move to /opt/
FLOORP_DIR=$(tar -tf "$FLOORP_ARCHIVE" | head -1 | cut -f1 -d"/")  # get top folder
if [[ -d "$FLOORP_DIR" ]]; then
  echo "[+] Installing Floorp to /opt..."
  sudo rm -rf /opt/floorp
  sudo mv "$FLOORP_DIR" /opt/floorp
  echo "[✓] Floorp installed at /opt/floorp"
else
  echo "[✗] Extracted Floorp directory not found."
  exit 1
fi

# Clean up archive
rm -f "$FLOORP_ARCHIVE"
sudo ln -sf /opt/floorp/floorp /usr/bin/floorp


prompt_confirm() {
    local prompt="$1"
    local response

    if [ -t 0 ]; then
        read -rp "$prompt [y/N]: " response
    else
        # Force prompt even in non-interactive shells
        echo -n "$prompt [y/N]: " > /dev/tty
        read -r response < /dev/tty
    fi

    [[ "$response" =~ ^[Yy]$ ]]
}


# === Copy dotfiles to Home Directory ===
echo "[+] Copying dotfiles to your home directory..."

shopt -s dotglob  # <--- Include hidden files like .themes, .icons, etc.

for file in ./*; do
    # Skip these explicitly
    [[ "$file" == "./.git" || "$file" == "./install.sh" ]] && continue

    # Ask before copying .bashrc
    if [[ "$file" == "./.bashrc" ]]; then
        if prompt_confirm "Do you want to overwrite .bashrc in your home directory?"; then
            sudo cp -rf "$file" "$HOME/"
        else
            echo "[✗] Skipped .bashrc"
            continue
        fi
    else
        sudo cp -rf "$file" "$HOME/"
    fi
done


# Copy rofi binary if it exists
if [[ -f ~/bin/rofi ]]; then
    echo "[+] Installing rofi to /usr/bin/..."
    sudo cp ~/bin/rofi /usr/bin/
fi

sudo cp "$HOME/bin/wallpaper-switch.sh" /usr/bin/
sudo cp "$HOME/bin/network_manager" /usr/local/bin/
sudo cp -r "$HOME/fonts" /usr/share/
sudo cp "$HOME/services/wallpaper-auto.service" /etc/systemd/user/
sudo cp "$HOME/services/wallpaper-auto.timer" /etc/systemd/user/
sudo cp "$HOME/services/floorp.desktop" /usr/share/applications/

echo "[+] Setting up Services..."

systemctl --user enable pipewire wireplumber pipewire-pulse
systemctl --user enable wallpaper-auto.timer
systemctl --user enable wallpaper-auto.service


# Fix ownership
sudo chown -R "$USER:$USER" "$HOME"

# === Package Install Section ===
echo "[+] Changing themes..."
kitty +kitten themes --reload-in=all "Elysia"
gsettings set org.gnome.desktop.interface gtk-theme "ElysiaOS"
gsettings set org.gnome.desktop.interface icon-theme "ElysiaOS"
gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
systemctl --user disable swaync
echo "[+] Updating fonts..."
fc-cache -f -v

# === Install Plymouth ===
echo "[+] Setting up Plymouth..."
sleep 2
if ! pacman -Q plymouth &>/dev/null; then
    echo "[+] Installing Plymouth..."
    sudo pacman -S --noconfirm plymouth
else
    echo "[✓] Plymouth is already installed."
fi

# === List available kernels and let user choose ===
echo "[+] Available Linux kernels:"
AVAILABLE_KERNELS=($(ls /boot | grep vmlinuz | sed 's/vmlinuz-//g'))

if [ ${#AVAILABLE_KERNELS[@]} -eq 0 ]; then
    echo "[-] No kernels found in /boot. Cannot proceed."
    exit 1
fi

for i in "${!AVAILABLE_KERNELS[@]}"; do
    echo "$((i+1)). ${AVAILABLE_KERNELS[i]}"
done

echo ""

# Loop until user provides valid input
while true; do
    read -p "Please select a kernel by number or type the kernel name: " KERNEL_CHOICE
    
    # Validate user input
    if [[ "$KERNEL_CHOICE" =~ ^[0-9]+$ ]]; then
        # User entered a number
        KERNEL_INDEX=$((KERNEL_CHOICE-1))
        if [ $KERNEL_INDEX -ge 0 ] && [ $KERNEL_INDEX -lt ${#AVAILABLE_KERNELS[@]} ]; then
            SELECTED_KERNEL="${AVAILABLE_KERNELS[$KERNEL_INDEX]}"
            break
        else
            echo "[-] Invalid selection. Try again and type correct one from the list."
            continue
        fi
    else
        # User entered a kernel name
        SELECTED_KERNEL="$KERNEL_CHOICE"
        # Verify the kernel exists
        if [[ " ${AVAILABLE_KERNELS[@]} " =~ " ${SELECTED_KERNEL} " ]]; then
            break
        else
            echo "[-] Kernel '$SELECTED_KERNEL' not found. Try again and type correct one from the list."
            continue
        fi
    fi
done

echo "[✓] Selected kernel: $SELECTED_KERNEL"

# === Edit mkinitcpio.conf to add plymouth ===
MKINITCONF="/etc/mkinitcpio.conf"
if ! grep -E "^HOOKS\s*=.*\bplymouth\b" "$MKINITCONF"; then
    echo "[+] Adding plymouth to mkinitcpio.conf HOOKS..."
    sudo sed -i 's/\(HOOKS\s*=(.*base udev\)/\1 plymouth/' "$MKINITCONF"
else
    echo "[✓] Plymouth already present in mkinitcpio.conf."
fi

# === Rebuild initramfs ===
echo "[+] Rebuilding initramfs with mkinitcpio for kernel: $SELECTED_KERNEL..."
sudo mkinitcpio -p "$SELECTED_KERNEL"

# === Copy Plymouth Theme ===
echo "[+] Installing Plymouth theme..."
sudo cp -r plymouth/themes/elysiaos-style2 /usr/share/plymouth/themes/
sudo plymouth-set-default-theme -R elysiaos-style2

# === Ensure /etc/plymouth/plymouthd.conf is correct ===
PLYMOUTH_CONF="/etc/plymouth/plymouthd.conf"
EXPECTED_THEME="Theme=elysiaos-style2"
EXPECTED_DELAY="ShowDelay=2"

echo "[+] Verifying $PLYMOUTH_CONF..."
if [ ! -f "$PLYMOUTH_CONF" ]; then
    echo "[+] Creating $PLYMOUTH_CONF..."
    echo -e "[Daemon]\n$EXPECTED_THEME\n$EXPECTED_DELAY" | sudo tee "$PLYMOUTH_CONF" >/dev/null
else
    # Ensure [Daemon] section exists
    if ! grep -q "^\[Daemon\]" "$PLYMOUTH_CONF"; then
        echo "[+] Adding [Daemon] section..."
        echo -e "\n[Daemon]\n$EXPECTED_THEME\n$EXPECTED_DELAY" | sudo tee -a "$PLYMOUTH_CONF" >/dev/null
    else
        # Fix Theme line inside [Daemon]
        sudo sed -i '/^\[Daemon\]/,/^\[.*\]/{s/^Theme=.*/'"$EXPECTED_THEME"'/}' "$PLYMOUTH_CONF"
        # Fix ShowDelay line
        if grep -q "^ShowDelay=" "$PLYMOUTH_CONF"; then
            sudo sed -i '/^\[Daemon\]/,/^\[.*\]/{s/^ShowDelay=.*/'"$EXPECTED_DELAY"'/}' "$PLYMOUTH_CONF"
        else
            sudo sed -i '/^\[Daemon\]/a '"$EXPECTED_DELAY" "$PLYMOUTH_CONF"
        fi
    fi
fi

# === Rebuild initramfs again ===
echo "[+] Rebuilding initramfs again after theme setup for kernel: $SELECTED_KERNEL..."
sudo mkinitcpio -p "$SELECTED_KERNEL"


# === SDDM Setup ===
echo "[+] Setting up SDDM and applying eucalyptus-drop theme..."

# 1. Install SDDM if not found
if ! command -v sddm &>/dev/null; then
    echo "[!] sddm not found. Installing..."
    sudo pacman -S --noconfirm sddm
else
    echo "[✓] sddm is already installed."
fi

# 2. Enable SDDM as the display manager
if ! systemctl is-enabled sddm &>/dev/null; then
    echo "[+] Enabling SDDM as default display manager..."
    sudo systemctl enable sddm
else
    echo "[✓] SDDM is already enabled."
fi

# 3. Copy the eucalyptus-drop theme
SDDM_THEME_SRC="SDDM/eucalyptus-drop"
SDDM_THEME_DEST="/usr/share/sddm/themes/eucalyptus-drop"
echo "[+] Installing eucalyptus-drop theme..."
sudo mkdir -p /usr/share/sddm/themes
sudo cp -r "$SDDM_THEME_SRC" /usr/share/sddm/themes/

# 4. Modify /etc/sddm.conf to use the theme
SDDM_CONF="/etc/sddm.conf"

if [ ! -f "$SDDM_CONF" ]; then
    echo "[+] Creating new /etc/sddm.conf with eucalyptus-drop theme..."
    echo -e "[Theme]\nCurrent=eucalyptus-drop" | sudo tee "$SDDM_CONF" >/dev/null
else
    if grep -q "^\[Theme\]" "$SDDM_CONF"; then
        if grep -q "^Current=" <(awk '/^\[Theme\]/{flag=1;next}/^\[.*\]/{flag=0}flag' "$SDDM_CONF"); then
            echo "[+] Updating existing 'Current=' in [Theme] section..."
            sudo sed -i '/^\[Theme\]/,/^\[/{s/^Current=.*/Current=eucalyptus-drop/}' "$SDDM_CONF"
        else
            echo "[+] Adding 'Current=' under existing [Theme] section..."
            sudo sed -i '/^\[Theme\]/a Current=eucalyptus-drop' "$SDDM_CONF"
        fi
    else
        echo "[+] Appending new [Theme] section..."
        echo -e "\n[Theme]\nCurrent=eucalyptus-drop" | sudo tee -a "$SDDM_CONF" >/dev/null
    fi
fi


# === Copy GRUB Theme ===
echo "[+] Installing GRUB theme..."
GRUB_THEME_SRC="GRUB-THEME/ElysianRealm"
GRUB_THEME_DEST="/boot/grub/themes/ElysianRealm"
sudo mkdir -p /boot/grub/themes
sudo cp -r "$GRUB_THEME_SRC" /boot/grub/themes/

# === Set GRUB_THEME in grub config ===
GRUB_FILE="/etc/default/grub"
THEME_LINE="GRUB_THEME=\"$GRUB_THEME_DEST/theme.txt\""

if grep -q "^GRUB_THEME=" "$GRUB_FILE"; then
    sudo sed -i "s|^GRUB_THEME=.*|$THEME_LINE|" "$GRUB_FILE"
else
    echo "$THEME_LINE" | sudo tee -a "$GRUB_FILE" >/dev/null
fi

# === Set GRUB_CMDLINE_LINUX_DEFAULT ===
echo "[+] Updating GRUB_CMDLINE_LINUX_DEFAULT..."
GRUB_CMDLINE='GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet splash rd.udev.log_priority=3 vt.global_cursor_default=0 usbcore.autosuspend=-1"'
sudo sed -i "s|^GRUB_CMDLINE_LINUX_DEFAULT=.*|$GRUB_CMDLINE|" "$GRUB_FILE"

# === Regenerate grub.cfg ===
echo "[+] Regenerating GRUB config..."
sudo grub-mkconfig -o /boot/grub/grub.cfg

# === Cleanup: Remove unneeded setup files from home ===
echo "[+] Cleaning up files from home directory..."
rm -rf "$HOME/SDDM" \
       "$HOME/GRUB-THEME" \
       "$HOME/assets" \
       "$HOME/services" \
       "$HOME/fonts" \
       "$HOME/plymouth" \
       "$HOME/elylogo.png" \
       "$HOME/README.md"

echo
echo "[+] ElysiaOS installation complete!"
echo

echo "[+] Rebooting..."
sleep 4
reboot
