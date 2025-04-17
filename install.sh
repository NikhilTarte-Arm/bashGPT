#!/bin/bash
# install_env.sh: Install dependencies, verify environment, and configure OpenAI API key.
#
# This Ubuntu-only installation script performs the following:
#   1. Ensures the operating system is Ubuntu.
#   2. Installs required packages (jq and curl).
#   3. Checks for an existing OpenAI API key in ~/.bashrc.
#      - If one is found, offers to keep or replace it (with up to 3 attempts if replacing).
#      - It verifies any provided key by contacting the OpenAI API.
#   4. Creates ~/bin (if it doesn't exist) and appends it to your PATH via ~/.bashrc.
#   5. Copies all scripts from the project's scripts/ directory to ~/bin and makes them executable.
#
# Usage:
#   ./install_env.sh

# --- 1. Verify that the system is Ubuntu ---
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [ "$ID" != "ubuntu" ]; then
        echo "This installation script is intended for Ubuntu systems. Detected system: $NAME."
        exit 1
    fi
else
    echo "Cannot determine the operating system. This script is intended for Ubuntu."
    exit 1
fi

# --- 2. Install required dependencies (jq and curl) ---
install_pkg() {
    local pkg="$1"
    if ! dpkg -s "$pkg" &> /dev/null; then
        echo "Installing $pkg..."
        sudo apt-get update && sudo apt-get install -y "$pkg"
        if [ $? -ne 0 ]; then
            echo "Error installing $pkg. Please install it manually."
            exit 1
        fi
    else
        echo "$pkg is already installed."
    fi
}

install_pkg jq
install_pkg curl

# --- Helper function: verify if an API key works by calling the OpenAI models endpoint ---
verify_key() {
    local key="$1"
    http_code=$(curl -s -o /dev/null -w "%{http_code}" https://api.openai.com/v1/models -H "Authorization: Bearer $key")
    if [ "$http_code" -eq 200 ]; then
        return 0
    else
        return 1
    fi
}

# --- 3. API Key handling & verification ---
RC_FILE="$HOME/.bashrc"
existing_key_line=$(grep "^export OPENAI_API_KEY=" "$RC_FILE" | head -n 1)
if [ -n "$existing_key_line" ]; then
    # Extract current key (remove quotes if present)
    current_key=$(echo "$existing_key_line" | cut -d '=' -f2- | tr -d '"')
    echo "An existing OpenAI API key was found in $RC_FILE."
    # Verify the existing key
    if verify_key "$current_key"; then
        echo "The existing key is valid."
    else
        echo "WARNING: The existing key appears to be invalid."
    fi
    echo "Press Enter to keep the existing key, or paste a new key to override it:"
    read -r new_key
    if [ -z "$new_key" ]; then
        key_to_use="$current_key"
        echo "Retaining the existing API key."
    else
        attempt=1
        while [ $attempt -le 3 ]; do
            if verify_key "$new_key"; then
                key_to_use="$new_key"
                echo "New API key is valid."
                break
            else
                echo "The provided API key is invalid. Please try again:"
                read -r new_key
            fi
            attempt=$((attempt + 1))
        done
        if [ -z "$key_to_use" ]; then
            echo "No valid API key provided after 3 attempts. Aborting installation."
            exit 1
        fi
        # Remove the old key line and update with the new key.
        sed -i '/^export OPENAI_API_KEY=/d' "$RC_FILE"
        echo "export OPENAI_API_KEY=\"$key_to_use\"" >> "$RC_FILE"
        echo "Updated API key in $RC_FILE."
    fi
else
    # No existing key; prompt user to enter one.
    attempt=1
    while [ $attempt -le 3 ]; do
         read -p "Enter your OpenAI API key: " new_key
         if [ -n "$new_key" ]; then
             if verify_key "$new_key"; then
                 key_to_use="$new_key"
                 echo "API key is valid."
                 break
             else
                 echo "The provided API key is invalid. Please try again."
             fi
         else
             echo "No key entered. Please try again."
         fi
         attempt=$((attempt + 1))
    done
    if [ -z "$key_to_use" ]; then
         echo "No valid API key provided after 3 attempts. Aborting installation."
         exit 1
    fi
    # Save the new key in ~/.bashrc.
    echo "export OPENAI_API_KEY=\"$key_to_use\"" >> "$RC_FILE"
    echo "API key saved to $RC_FILE."
fi

# --- 4. Create ~/bin directory and update PATH ---
BIN_DIR="$HOME/bin"
if [ ! -d "$BIN_DIR" ]; then
    mkdir -p "$BIN_DIR"
    echo "Created directory: $BIN_DIR"
fi

if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    echo "Adding $BIN_DIR to PATH in $RC_FILE"
    echo "export PATH=\"\$HOME/bin:\$PATH\"" >> "$RC_FILE"
fi

# --- 5. Copy all scripts from the project's scripts/ directory to ~/bin ---
SCRIPT_SRC_DIR="$(pwd)/scripts"
if [ ! -d "$SCRIPT_SRC_DIR" ]; then
    echo "Scripts directory not found at $SCRIPT_SRC_DIR. Nothing to install."
    exit 1
fi

for script in "$SCRIPT_SRC_DIR"/*; do
    if [ -f "$script" ]; then
        cp "$script" "$BIN_DIR/"
        chmod +x "$BIN_DIR/$(basename "$script")"
        echo "Installed $(basename "$script") to $BIN_DIR"
    fi
done

echo "Installation complete."
echo "Please open a new terminal session or run 'source $RC_FILE' to load the changes."
echo "Your project scripts have been copied to $BIN_DIR and are now available in your PATH."
