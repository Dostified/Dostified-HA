#!/data/data/com.termux/files/usr/bin/bash

VENV_DIR="$HOME/homeassistant"
SHORTCUTS_DIR="$HOME/.shortcuts"

# Function to automatically generate widget shortcuts
create_shortcuts() {
    echo "[*] Creating homescreen widget shortcuts..."
    mkdir -p "$SHORTCUTS_DIR"
    
    # 1. Shortcut for this Master Menu
    echo "#!/data/data/com.termux/files/usr/bin/bash" > "$SHORTCUTS_DIR/HA_Master_Menu.sh"
    echo "bash ~/install_ha.sh" >> "$SHORTCUTS_DIR/HA_Master_Menu.sh"
    chmod +x "$SHORTCUTS_DIR/HA_Master_Menu.sh"

    # 2. Shortcut for starting Home Assistant
    echo "#!/data/data/com.termux/files/usr/bin/bash" > "$SHORTCUTS_DIR/Start_HA.sh"
    echo "source ~/homeassistant/bin/activate && hass -v" >> "$SHORTCUTS_DIR/Start_HA.sh"
    chmod +x "$SHORTCUTS_DIR/Start_HA.sh"

    echo "[✓] Widget shortcuts generated successfully!"
    sleep 2
}

install_dependencies() {
    echo "[*] Updating packages and installing system dependencies..."
    pkg update -y && pkg upgrade -y
    pkg install python rust make clang libffi openssl -y
}

# Infinite loop for the interactive menu
while true; do
    clear
    echo "================================================="
    echo "      Dostified Reviews: HA Master Setup Tool    "
    echo "================================================="
    echo "  1) Check Installation Status"
    echo "  2) Fresh Install (First time users)"
    echo "  3) Reinstall (Keeps your smart home data safe)"
    echo "  4) Fix Issues / Repair Environment"
    echo "  5) Generate Widget Shortcuts"
    echo "  6) Exit Menu"
    echo "================================================="
    
    # The magic fix: </dev/tty forces it to listen to the user's keyboard
    read -p "Select an option [1-6]: " choice </dev/tty

    case $choice in
        1)
            echo ""
            echo "[*] Checking installation status..."
            if [ -d "$VENV_DIR" ]; then
                echo "[✓] Environment folder found."
                source "$VENV_DIR/bin/activate"
                if command -v hass >/dev/null 2>&1; then
                    echo "[✓] Home Assistant Core is installed and accessible."
                    echo "[*] You are ready to run: Start_HA.sh"
                else
                    echo "[!] Environment exists, but Home Assistant is broken or missing."
                fi
            else
                echo "[!] No Home Assistant installation found. Please run Option 2."
            fi
            read -p "Press Enter to return to menu..." </dev/tty
            ;;
        2)
            echo ""
            echo "--- [ FRESH INSTALLATION ] ---"
            if [ -d "$VENV_DIR" ]; then
                echo "[!] An installation already exists. Use Option 3 to reinstall."
            else
                install_dependencies
                echo "[*] Creating isolated Python environment..."
                python -m venv "$VENV_DIR"
                source "$VENV_DIR/bin/activate"
                echo "[*] Downloading and installing Home Assistant..."
                pip install --upgrade pip wheel homeassistant
                echo "[✓] Fresh installation complete!"
                create_shortcuts
            fi
            read -p "Press Enter to return to menu..." </dev/tty
            ;;
        3)
            echo ""
            echo "--- [ REINSTALLATION ] ---"
            install_dependencies
            echo "[*] Wiping old system files..."
            rm -rf "$VENV_DIR"
            echo "[*] Building fresh environment..."
            python -m venv "$VENV_DIR"
            source "$VENV_DIR/bin/activate"
            echo "[*] Reinstalling Home Assistant core..."
            pip install --upgrade pip wheel homeassistant
            echo "[✓] Reinstallation complete! Your config data was not touched."
            create_shortcuts
            read -p "Press Enter to return to menu..." </dev/tty
            ;;
        4)
            echo ""
            echo "--- [ FIX / REPAIR ] ---"
            if [ -d "$VENV_DIR" ]; then
                echo "[*] Attempting to repair core packages..."
                source "$VENV_DIR/bin/activate"
                pip install --upgrade pip wheel homeassistant
                echo "[✓] Repair process finished."
            else
                echo "[!] Cannot repair: No installation found. Run Option 2 instead."
            fi
            read -p "Press Enter to return to menu..." </dev/tty
            ;;
        5)
            echo ""
            create_shortcuts
            read -p "Press Enter to return to menu..." </dev/tty
            ;;
        6)
            echo ""
            echo "Exiting Dostified Reviews Master Tool. Goodbye!"
            break
            ;;
        *)
            echo "Invalid option. Please enter a number from 1 to 6."
            sleep 2
            ;;
    esac
done
