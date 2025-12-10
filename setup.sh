#!/bin/bash

set -e

# === CONFIGURATION ===
CONTAINER_NAME="kali-container"
SHARE_PATH="$HOME/Desktop/kali-share"
IMAGE="docker.io/kalilinux/kali-rolling:latest"
ZSHRC="$HOME/.zshrc"

# Resource limits (leave empty "" to disable)
CONTAINER_CPUS=""
CONTAINER_MEMORY=""

echo "[] Starting Kali setup with Apple's container system..."

# --- Check if brew is installed ---
if ! command -v brew &>/dev/null; then
    echo "[!] Homebrew not found. Please install Homebrew first: https://brew.sh/"
    return 1 2>/dev/null || exit 1
fi

# --- Check if container CLI is installed ---
if ! command -v container &>/dev/null; then
    echo "[] Installing Apple's container CLI..."
    brew install --cask container
else
    echo "[] container CLI already installed."
fi

# --- Start container system ---
echo "[] Starting container system..."
container system start || true

# --- Ensure shared directory exists ---
if [ ! -d "$SHARE_PATH" ]; then
    echo "[] Creating shared directory at $SHARE_PATH..."
    mkdir -p "$SHARE_PATH"
fi

# --- Remove old aliases if they exist ---
sed -i '' '/alias kali=/d' "$ZSHRC"
sed -i '' '/alias kali-shell=/d' "$ZSHRC"
sed -i '' '/alias kali-start=/d' "$ZSHRC"

# --- Build run command parts ---
RUN_PARTS=("container run")

if [ -n "$CONTAINER_CPUS" ]; then
    RUN_PARTS+=("--cpus" "$CONTAINER_CPUS")
fi

if [ -n "$CONTAINER_MEMORY" ]; then
    RUN_PARTS+=("--memory" "$CONTAINER_MEMORY")
fi

RUN_PARTS+=("--interactive" "--name" "$CONTAINER_NAME" "--tty" "--volume" "$SHARE_PATH:/kali-share" "--workdir" "/kali-share" "$IMAGE")

# Join array into single alias safely
KALI_START_CMD="${RUN_PARTS[*]}"

# --- Add aliases to .zshrc ---
echo "alias kali='container start $CONTAINER_NAME --interactive'" >> "$ZSHRC"
echo "[] Installed alias: kali"

echo "alias kali-shell='container exec --interactive --tty $CONTAINER_NAME /bin/bash'" >> "$ZSHRC"
echo "[] Installed alias: kali-shell"

echo "alias kali-start='$KALI_START_CMD'" >> "$ZSHRC"
echo "[] Installed alias: kali-start"

# --- Detect if script is sourced ---
(
    if [[ -n "$ZSH_EVAL_CONTEXT" && "$ZSH_EVAL_CONTEXT" =~ :file ]]; then
        IS_SOURCED=1
    elif [ "$0" = "bash" ]; then
        IS_SOURCED=1
    else
        IS_SOURCED=0
    fi

    if [ "$IS_SOURCED" -eq 1 ]; then
        echo "[] Script was sourced. Reloading $ZSHRC..."
        # shellcheck disable=SC1090
        source "$ZSHRC"
        echo "[✓] Aliases are now active in this session."
    else
        echo "[!] Script was executed directly."
        echo ">>> Run 'source ~/.zshrc' or restart your terminal to enable the aliases."
    fi
)

# --- Build container run options (reuse logic) ---
RUN_OPTS=()
if [ -n "$CONTAINER_CPUS" ]; then
    RUN_OPTS+=(--cpus "$CONTAINER_CPUS")
fi
if [ -n "$CONTAINER_MEMORY" ]; then
    RUN_OPTS+=(--memory "$CONTAINER_MEMORY")
fi

# --- Clean up any existing container ---
echo "[] Checking for existing container artifacts..."
if container list --all | grep -q "$CONTAINER_NAME"; then
    echo "[] Removing existing container..."
    container stop "$CONTAINER_NAME" 2>/dev/null || true
    container rm "$CONTAINER_NAME" 2>/dev/null || true
fi

# --- Create Kali container ---
echo "[] Creating new Kali container '$CONTAINER_NAME'..."
container run --interactive --tty \
    --name "$CONTAINER_NAME" \
    --volume "$SHARE_PATH:/kali-share" \
    --workdir /kali-share \
    "${RUN_OPTS[@]}" \
    "$IMAGE"

echo "[✓] Setup complete!"
echo "[✓] Use 'kali-start' to start the container and 'kali-shell' to get a shell inside it."
